
resource "aws_iam_role" "lambda" {
  name = "lambda_iam"

  assume_role_policy = <<ROLEPOLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Sid": ""
    }
  ]
}
ROLEPOLICY
}

module "agent" {
//  source = "github.com/ronnathaniel/terraform-module-epsagon/tree/main/modules/tracing_agent_layer"
  source = "../../modules/tracing_agent_layer/"
}

data "archive_file" "lambda-archive" {
  type = "zip"
  source_file = "src/main.py"
  output_path = "function_package.zip"
}

resource "aws_lambda_function" "tf_test" {
  function_name = "tf_test_ron"
  handler       = "main.handler"
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.8"

  filename         = "function_package.zip"
  source_code_hash = filebase64sha256("function_package.zip")
  environment {
    variables = {
      KEY = "val"
    }
  }
}