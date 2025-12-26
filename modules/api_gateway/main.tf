resource "aws_apigatewayv2_api" "this" {
  name          = "med-hipaa-dev-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id = aws_apigatewayv2_api.this.id
  name   = "dev"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"
  connection_type  = "INTERNET"
  description      = "Proxy integration to EC2 app"
  integration_uri  = "http://${aws_instance.app.public_ip}:3000" # Replace with your EC2 instance or ALB DNS
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_instance" "app" {
  ami                    = "ami-0abcdef1234567890" # Replace with a valid AMI
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  key_name               = "med_hippa"
  vpc_security_group_ids = [var.app_sg_id]
}
resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "med-hipaa-vpc-link"
  subnet_ids         = var.subnet_id # or var.subnet_ids
  security_group_ids = [var.app_sg_id]
}