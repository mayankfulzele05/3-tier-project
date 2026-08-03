############################################
# Create prod namespace
############################################

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
}

############################################
# AWS Secrets Manager Secret
############################################

resource "aws_secretsmanager_secret" "mysql" {
  name        = "prod/mysql-secret"
  description = "MySQL credentials for prod namespace"
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id

  secret_string = jsonencode({
    MYSQL_ROOT_PASSWORD = "rootpass"
    MYSQL_DATABASE      = "test_db"
    MYSQL_USER          = "appuser"
    MYSQL_PASSWORD      = "apppass"
    DATABASE_URL        = "mysql://appuser:apppass@mysql:3306/test_db"
  })
}

############################################
# Existing EKS Cluster
############################################

data "aws_eks_cluster" "cluster" {
  name = "cluster"
}

############################################
# Existing EKS OIDC Provider
############################################

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

############################################
# IRSA Trust Policy
############################################

data "aws_iam_policy_document" "eso_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:prod:eso-prod-sa"
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

############################################
# IAM Role
############################################

resource "aws_iam_role" "eso_prod" {
  name               = "eso-prod-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
}

############################################
# IAM Policy
############################################

data "aws_iam_policy_document" "eso_policy" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      "${aws_secretsmanager_secret.mysql.arn}*"
    ]
  }
}

resource "aws_iam_policy" "eso_prod" {
  name   = "ESOSecretsManagerPRODReadPolicy"
  policy = data.aws_iam_policy_document.eso_policy.json
}

############################################
# Attach Policy
############################################

resource "aws_iam_role_policy_attachment" "eso_prod" {
  role       = aws_iam_role.eso_prod.name
  policy_arn = aws_iam_policy.eso_prod.arn
}

############################################
# Service Account
############################################

resource "kubernetes_service_account" "eso_prod" {
  metadata {
    name      = "eso-prod-sa"
    namespace = kubernetes_namespace.prod.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eso_prod.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eso_prod
  ]
}
