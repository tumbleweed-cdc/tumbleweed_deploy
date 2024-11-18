resource "aws_lambda_function" "authorizer" {
  function_name = "myAuthorizer"
  handler       = "authorizer.handler"  # Adjust based on your compiled output
  runtime       = "nodejs14.x"           # Use the appropriate Node.js runtime
  role          = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("path/to/your/authorizer.zip")
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "MyAPI"
  description = "My API with TypeScript Lambda Authorizer"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "myresource"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                    = "MyAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials  = aws_iam_role.lambda_exec.arn
  identity_source        = "method.request.header.Authorization"
  type                   = "TOKEN"
}

