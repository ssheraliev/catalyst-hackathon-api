# AWS IAM role and policies required
data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "../lambda-func/lambda_handler.py"
  output_path = "lambda-handler.zip"
}

# IAM Role for EKS Provisioner
resource "aws_iam_role" "eks_provisioner_role" {
  name = "eks_provisioner_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "eks_provisioner_policy" {
  name = "eks_provisioner_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateCluster",
          "ec2:DescribeCluster",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "iam:CreateServiceRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:DeleteRolePolicy",
          "iam:CreateRole",
          "iam:GetRole",
          "iam:DeleteRole",
          "iam:ListRoles",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "securitygroup:CreateSecurityGroup",
          "securitygroup:DeleteSecurityGroup",
          "securitygroup:DescribeSecurityGroups",
          "securitygroup:AuthorizeSecurityGroupIngress",
          "securitygroup:RevokeSecurityGroupIngress",
          "subnet:CreateSubnet",
          "subnet:DescribeSubnets",
          "vpc:CreateVpc",
          "vpc:DescribeVpcs",
          "sns:Publish"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_role_attachment" {
  role       = aws_iam_role.eks_provisioner_role.name
  policy_arn = aws_iam_policy.eks_provisioner_policy.arn
}

# IAM Role for RDS Provisioner
resource "aws_iam_role" "rds_provisioner_role" {
  name = "rds_provisioner_role"

  assume_role_policy = aws_iam_role.eks_provisioner_role.assume_role_policy
}

resource "aws_iam_policy" "rds_provisioner_policy" {
  name = "rds_provisioner_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:CreateDBInstance",
          "rds:DescribeDBInstances",
          "iam:PassRole",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_role_attachment" {
  role       = aws_iam_role.rds_provisioner_role.name
  policy_arn = aws_iam_policy.rds_provisioner_policy.arn
}

# IAM Role for ElastiCache Provisioner

resource "aws_iam_role" "elasticache_provisioner_role" {
  name = "elasticache_provisioner_role"

  assume_role_policy = aws_iam_role.eks_provisioner_role.assume_role_policy
}

resource "aws_iam_policy" "elasticache_provisioner_policy" {
  name = "elasticache_provisioner_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticache:CreateCacheCluster",
          "elasticache:DescribeCacheClusters",
          "iam:PassRole",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elasticache_role_attachment" {
  role       = aws_iam_role.elasticache_provisioner_role.name
  policy_arn = aws_iam_policy.elasticache_provisioner_policy.arn
}

# Lambda Functions with Separate Roles

resource "aws_lambda_function" "eks_provisioner" {
  function_name = "eks-provisioner"
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.9"
  filename      = data.archive_file.python_lambda_package.output_path
  role          = aws_iam_role.eks_provisioner_role.arn

  depends_on = [aws_iam_role_policy_attachment.eks_role_attachment]
}

resource "aws_lambda_function" "rds_provisioner" {
  function_name = "rds-provisioner"
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.9"
  filename      = data.archive_file.python_lambda_package.output_path
  role          = aws_iam_role.rds_provisioner_role.arn

  depends_on = [aws_iam_role_policy_attachment.rds_role_attachment]
}

resource "aws_lambda_function" "elasticache_provisioner" {
  function_name = "elasticache-provisioner"
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.9"
  filename      = data.archive_file.python_lambda_package.output_path
  role          = aws_iam_role.elasticache_provisioner_role.arn

  depends_on = [aws_iam_role_policy_attachment.elasticache_role_attachment]
}