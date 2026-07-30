# 1. Create the GitHub OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://githubusercontent.com"
  client_id_list  = ["://amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. Create the IAM Role with the Github Trust Policy
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
            "://githubusercontent.com:aud" = "://amazonaws.com"
          }
          StringLike = {
            "://githubusercontent.com:sub" = "repo:mayankfulzele05/3-tier-project.git:ref:refs/heads/qa"
          }
        }
      }
    ]
  })
}

# 3. Create the Custom EKS Describe Cluster IAM Policy
resource "aws_iam_policy" "eks_describe_policy" {
  name        = "GitHubActionsEKSDescribeClusterPolicy"
  description = "Allows GitHub Actions to describe the EKS QA cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EKSDescribeCluster"
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "arn:aws:eks:ap-south-1:896568317269:cluster/cluster"
      }
    ]
  })
}

# 4. Attach the Custom Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "attach_describe_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.eks_describe_policy.arn
}

# 5. Create EKS Access Entry for the IAM Role
resource "aws_eks_access_entry" "github_access_entry" {
  cluster_name  = "cluster"
  principal_arn = aws_iam_role.github_actions_role.arn
  type          = "STANDARD"
}

# 6. Associate AmazonEKSEditPolicy with Namespace Access Scope
resource "aws_eks_access_policy_association" "github_edit_policy" {
  cluster_name  = "cluster"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  principal_arn = aws_iam_role.github_actions_role.arn

  access_scope {
    type       = "namespace"
    namespaces = ["qa"]
  }
}
