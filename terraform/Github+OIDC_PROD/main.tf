########################################
# Existing GitHub OIDC Provider
########################################

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

########################################
# Existing IAM Policy
########################################

data "aws_iam_policy" "eks_describe_cluster" {
  arn = "arn:aws:iam::896568317269:policy/GitHubActionsEKSDescribeClusterPolicy"
}

########################################
# GitHub Actions Trust Policy
########################################

data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:mayankfulzele05/3-tier-project:ref:refs/heads/main"
      ]
    }
  }
}

########################################
# IAM Role
########################################

resource "aws_iam_role" "github_actions_prod" {
  name               = "GitHubActionsEKSDeployRolePROD"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
}

########################################
# Attach Existing IAM Policy
########################################

resource "aws_iam_role_policy_attachment" "eks_describe_attach" {
  role       = aws_iam_role.github_actions_prod.name
  policy_arn = data.aws_iam_policy.eks_describe_cluster.arn
}

########################################
# EKS Access Entry
########################################

resource "aws_eks_access_entry" "github_prod" {
  cluster_name  = "cluster"
  principal_arn = aws_iam_role.github_actions_prod.arn
  type          = "STANDARD"
}

########################################
# Associate AmazonEKSEditPolicy
########################################

resource "aws_eks_access_policy_association" "github_prod_edit" {
  cluster_name  = "cluster"
  principal_arn = aws_iam_role.github_actions_prod.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["prod"]
  }

  depends_on = [
    aws_eks_access_entry.github_prod
  ]
}
