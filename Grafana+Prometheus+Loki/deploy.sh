#!/bin/bash

set -euo pipefail

# ============================================================
# deploy.ps1
# Grafana Observability Stack for EKS
# Components: Prometheus · Loki · Grafana Alloy · Grafana
# Target app namespace: qa
# Run: .\deploy.ps1
# ============================================================

# ════════════════════════════════════════════════════════════
#  EDIT THESE BEFORE RUNNING
# ════════════════════════════════════════════════════════════
S3_BUCKET="qa-demo-00997"
AWS_REGION="ap-south-1"
CLUSTER_NAME="cluster"
MONITORING_NS="monitoring"
QA_NS="qa"
GRAFANA_ADMIN_PASSWORD="admin123"
NODE_ROLE_NAME="example-eks-node-group-dc46a6fef4747d8ac143aade82"

PROMETHEUS_CHART_VERSION="67.4.0"
LOKI_CHART_VERSION="6.29.0"
ALLOY_CHART_VERSION="0.12.0"
GRAFANA_CHART_VERSION="8.10.4"

# ── Helpers ──────────────────────────────────────────────────
log() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
}

step() {
    echo
    echo -e "\e[36m══ $1\e[0m"
}

die() {
    echo -e "\e[31m[ERROR]\e[0m $1"
    exit 1
}

# ── Pre-flight ────────────────────────────────────────────────
step "Pre-flight checks"

command -v helm >/dev/null 2>&1 || die "helm not installed"
command -v kubectl >/dev/null 2>&1 || die "kubectl not installed"
command -v aws >/dev/null 2>&1 || die "AWS CLI not installed"

CONTEXT=$(kubectl config current-context)

log "kubectl context : $CONTEXT"
log "AWS Region      : $AWS_REGION"
log "Cluster         : $CLUSTER_NAME"
log "S3 Bucket       : $S3_BUCKET"

read -p "Proceed with deployment? (y/n): " CONFIRM
[[ "$CONFIRM" != "y" ]] && die "Deployment cancelled"
# ── Namespaces ────────────────────────────────────────────────
# ── Creating namespaces ──────────────────────────────────────
step "Creating namespaces"

kubectl create namespace "$MONITORING_NS" --dry-run=client -o yaml | kubectl apply --server-side -f -
kubectl create namespace "$QA_NS" --dry-run=client -o yaml | kubectl apply --server-side -f -


kubectl label namespace "$MONITORING_NS" kubernetes.io/metadata.name="${MONITORING_NS}" --overwrite
kubectl label namespace "$QA_NS" kubernetes.io/metadata.name="${QA_NS}" --overwrite


# ── Grafana admin secret ──────────────────────────────────────
step "Creating Grafana admin secret"

kubectl create secret generic grafana-admin-secret \
    --namespace "$MONITORING_NS" \
    --from-literal=admin-user=admin \
    --from-literal=admin-password="$GRAFANA_ADMIN_PASSWORD" \
    --dry-run=client -o yaml | kubectl apply -f -

log "Secret: grafana-admin-secret created"

# ── S3 bucket for Loki ────────────────────────────────────────
step "Setting up S3 bucket for Loki: $S3_BUCKET"

if aws s3 ls "s3://$S3_BUCKET" >/dev/null 2>&1
then
    log "Bucket already exists"
else
    log "Creating bucket..."

    # Check region to prevent us-east-1 API failures
    if [[ "$AWS_REGION" == "us-east-1" ]]; then
        aws s3api create-bucket \
            --bucket "$S3_BUCKET" \
            --region "$AWS_REGION"
    else
        aws s3api create-bucket \
            --bucket "$S3_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi

    aws s3api put-public-access-block \
        --bucket "$S3_BUCKET" \
        --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

    # Creating lifecycle configuration file
    cat <<EOF > lifecycle.json
{
  "Rules": [{
    "ID": "loki-log-expiry",
    "Status": "Enabled",
    "Filter": {
      "Prefix": ""
    },
    "Expiration": {
      "Days": 35
    },
    "NoncurrentVersionExpiration": {
      "NoncurrentDays": 7
    }
  }]
}
EOF

    aws s3api put-bucket-lifecycle-configuration \
        --bucket "$S3_BUCKET" \
        --lifecycle-configuration file://lifecycle.json

    rm -f lifecycle.json
    log "Bucket created with lifecycle policy (35-day expiry)"
fi


# ── IAM policy for Loki S3 access ─────────────────────────────
# ── Setting up IAM policy for Loki S3 access ──────────────────
step "Setting up IAM policy for Loki S3 access"

# Patch the bucket name into the policy file (Mac/Linux compatible sed syntax)
sed -i.bak "s|<qa-demo-00997>|$S3_BUCKET|g" 05-loki-s3-iam-policy.json && rm -f 05-loki-s3-iam-policy.json.bak

# Check if LokiS3Policy already exists
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/LokiS3Policy"

if aws iam get-policy --policy-arn "$POLICY_ARN" >/dev/null 2>&1
then
    log "LokiS3Policy exists - updating..."

    aws iam create-policy-version \
        --policy-arn "$POLICY_ARN" \
        --policy-document file://05-loki-s3-iam-policy.json \
        --set-as-default
else
    log "Creating LokiS3Policy..."

    POLICY_ARN=$(aws iam create-policy \
        --policy-name LokiS3Policy \
        --policy-document file://05-loki-s3-iam-policy.json \
        --query Policy.Arn \
        --output text)
fi

# Attach to node role (Added missing backslash line continuation)
log "Attaching LokiS3Policy to node role: $NODE_ROLE_NAME"
aws iam attach-role-policy \
    --role-name "$NODE_ROLE_NAME" \
    --policy-arn "$POLICY_ARN"

log "IAM policy attached"

# Patch S3 bucket name and region into loki values
sed -i.bak \
-e "s|YOUR_S3_BUCKET|$S3_BUCKET|g" \
-e "s|ap-south-1|$AWS_REGION|g" \
02-loki-values.yaml && rm -f 02-loki-values.yaml.bak

# ── Helm repos ────────────────────────────────────────────────
step "Adding & updating Helm repos"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana               https://grafana.github.io/helm-charts
helm repo add eks                   https://aws.github.io/eks-charts
helm repo update

log "Repos updated"

# ── AWS Load Balancer Controller ──────────────────────────────
step "Checking AWS Load Balancer Controller"

if helm status aws-load-balancer-controller -n kube-system >/dev/null 2>&1
then
    log "AWS Load Balancer Controller already installed"
else
    warn "AWS Load Balancer Controller not found - installing..."
    warn "Make sure your node IAM role has AWSLoadBalancerControllerIAMPolicy attached."

    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        --namespace kube-system \
        --set "clusterName=$CLUSTER_NAME" \
        --set serviceAccount.create=true \
        --set serviceAccount.name=aws-load-balancer-controller \
        --wait \
        --timeout 5m

    log "AWS Load Balancer Controller installed"
fi

# ── 1. Prometheus ─────────────────────────────────────────────
step "1/4 Installing kube-prometheus-stack"

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
    --namespace "$MONITORING_NS" \
    --values 01-prometheus-values.yaml \
    --version "$PROMETHEUS_CHART_VERSION" \
    --wait \
    --timeout 10m

log "Prometheus stack installed"

# ── 2. Loki ───────────────────────────────────────────────────
step "2/4 Installing Loki"

helm upgrade --install loki grafana/loki \
    --namespace "$MONITORING_NS" \
    --values 02-loki-values.yaml \
    --version "$LOKI_CHART_VERSION" \
    --wait \
    --timeout 10m

log "Loki installed"

# ── 3. Grafana Alloy ──────────────────────────────────────────
step "3/4 Installing Grafana Alloy"

helm upgrade --install alloy grafana/alloy \
    --namespace "$MONITORING_NS" \
    --values 03-alloy-values.yaml \
    --version "$ALLOY_CHART_VERSION" \
    --wait \
    --timeout 10m

log "Grafana Alloy installed"


# ── 4. Grafana ────────────────────────────────────────────────
# ── 4. Grafana ────────────────────────────────────────────────
step "4/4 Installing Grafana"

helm upgrade --install grafana grafana/grafana \
    --namespace "$MONITORING_NS" \
    --values 04-grafana-values.yaml \
    --version "$GRAFANA_CHART_VERSION" \
    --set ingress.enabled=true \
    --set ingress.ingressClassName=alb \
    --set "ingress.path=/" \
    --set "ingress.pathType=Prefix" \
    --wait \
    --timeout 10m

log "Grafana installed"

# ── Verify ────────────────────────────────────────────────────
step "Pod status in namespace: $MONITORING_NS"
kubectl get pods -n "$MONITORING_NS" -o wide

step "Ingress status - ALB needs ~2-3 min to provision"
kubectl get ingress -n "$MONITORING_NS"

# ── Get admin password ────────────────────────────────────────
step "Verifying Grafana admin secret validation"
PASSWORD=$(kubectl get secret grafana-admin-secret \
    -n "$MONITORING_NS" \
    -o jsonpath="{.data.admin-password}" | base64 -d)

# ── Summary ───────────────────────────────────────────────────
echo
echo "=============================================="
echo "Deployment Complete!"
echo "=============================================="
echo
echo "Grafana User: admin"
echo "Grafana Password (Decoded from Cluster): $PASSWORD"
echo
echo "To fetch your Application Load Balancer URL, run:"
echo "kubectl get ingress grafana -n $MONITORING_NS"
