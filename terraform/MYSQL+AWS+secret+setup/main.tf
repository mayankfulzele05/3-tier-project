# --- 1. Kubernetes Namespace Provisioning ---
resource "kubernetes_namespace" "qa" {
  metadata {
    name = "qa"
  }
}

# --- 2. AWS Secrets Manager Management ---
resource "aws_secretsmanager_secret" "mysql_secret" {
  name                    = "qa/mysql-secret"
  description             = "MySQL credentials for qa namespace"
  recovery_window_in_days = 0 # Force-deletes instantly upon destruction if needed
}

resource "aws_secretsmanager_secret_version" "mysql_secret_val" {
  secret_id = aws_secretsmanager_secret.mysql_secret.id
  secret_string = jsonencode({
    MYSQL_ROOT_PASSWORD = "rootpass"
    MYSQL_DATABASE      = "test_db"
    MYSQL_USER          = "appuser"
    MYSQL_PASSWORD      = "apppass"
    DATABASE_URL        = "mysql://appuser:apppass@mysql:3306/test_db"
  })
}

# --- 3. Helm Deployment for External Secrets Operator ---
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
}

# --- 4. IAM OIDC for Service Accounts Setup ---
data "aws_iam_openid_connect_provider" "eks_oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# --- 5. ESO Service Account Core Setup ---
resource "aws_iam_role" "eso_qa_role" {
  name = "eso-qa-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:qa:eso-qa-sa"
            "${replace(data.aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eso_qa_policy" {
  name = "ESOSecretsManagerReadPolicy"
  role = aws_iam_role.eso_qa_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "${aws_secretsmanager_secret.mysql_secret.arn}*"
      }
    ]
  })
}

resource "kubernetes_service_account" "eso_qa_sa" {
  metadata {
    name      = "eso-qa-sa"
    namespace = kubernetes_namespace.qa.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eso_qa_role.arn
    }
  }
}

# --- 6. EBS CSI Driver Core Addon Setup ---
resource "aws_iam_role" "ebs_csi_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(data.aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"

          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attach" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = data.aws_eks_cluster.cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_update = "OVERWRITE"

 depends_on = [
  aws_iam_role_policy_attachment.ebs_csi_policy_attach
]

}
