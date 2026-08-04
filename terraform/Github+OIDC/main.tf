# ---------------------------------------------------------
# 1. GitHub OIDC Identity Provider
# ---------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# ---------------------------------------------------------
# 2. IAM Role for GitHub Actions
# ---------------------------------------------------------

resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsEKSDeployRoleQA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:mayankfulzele05/3-tier-project:ref:refs/heads/qa"
          }
        }
      }
    ]
  })
}

# ---------------------------------------------------------
# 3. EKS Describe Cluster Policy
# ---------------------------------------------------------

resource "aws_iam_policy" "eks_describe_policy" {

  name        = "GitHubActionsEKSDescribeClusterPolicy"

  description = "Allows GitHub Actions to describe the QA EKS Cluster"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Sid = "DescribeCluster"

        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = "arn:aws:eks:ap-south-1:896568317269:cluster/cluster"
      }
    ]
  })
}

# ---------------------------------------------------------
# 4. Attach Policy to IAM Role
# ---------------------------------------------------------

resource "aws_iam_role_policy_attachment" "attach_describe_policy" {

  role = aws_iam_role.github_actions_role.name

  policy_arn = aws_iam_policy.eks_describe_policy.arn
}

# ---------------------------------------------------------
# 5. Create EKS Access Entry
# ---------------------------------------------------------

resource "aws_eks_access_entry" "github_access_entry" {

  cluster_name = "cluster"

  principal_arn = aws_iam_role.github_actions_role.arn

  type = "STANDARD"
}

# ---------------------------------------------------------
# 6. Give Namespace Access
# ---------------------------------------------------------

resource "aws_eks_access_policy_association" "github_edit_policy" {

  cluster_name = "cluster"

  principal_arn = aws_iam_role.github_actions_role.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {

    type = "namespace"

    namespaces = [
      "qa"
    ]
  }
}

# ---------------------------------------------------------
# 7. Output Role ARN
# ---------------------------------------------------------

output "github_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
