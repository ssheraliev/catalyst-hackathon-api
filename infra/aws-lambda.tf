resource "aws_lambda_function" "service_provisioner" {
  # Path to combined Lambda function
  filename = "../lambda-func/lambda_handler.py"
  # Handler function within the code
  handler  = "lambda_handler.lambda_handler"

  # Function name for Lambda function
  function_name = "<lambda-function-name>"

  # Environment variables for the Lambda function
  environment {
    variables = {
      # Diagrid Catalyst region
      "DIAGRID_REGION" = "us-west-1"
    }
  }

  # IAM role for the Lambda function
  role = aws_iam_role.lambda_role.arn
}

# Resource to define the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  # Name for the IAM role
  name = "lambda_provisioner_role"

  # Assume the role
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

  # attaching IAM policy document(s)
  # ... (add policy documents)
}

# Resource to define the IAM policy for the Lambda function
resource "aws_iam_policy" "lambda_provisioner_policy" {
  # Name for the IAM policy
  name = "lambda_provisioner_policy"

  # Policy document with permissions for the Lambda function
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        # Allow Diagrid Catalyst API calls
        "Effect": "Allow",
        "Action": [
          "diagrid:StartWorkflow"
        ],
        # Allow access to specific Diagrid resources
        "Resource": [
          "arn:aws:diagrid:<region>:<account-id>:apps/<app-id>/workflows/*"
        ]
      },
    ]
  })
}

# Resource to attach the IAM policy to the IAM role
resource "aws_iam_role_attachment" "lambda_role_attachment" {
  # Reference to the IAM role
  role       = aws_iam_role.lambda_role.arn
  # Reference to the IAM policy
  policy_arn = aws_iam_policy.lambda_provisioner_policy.arn
}