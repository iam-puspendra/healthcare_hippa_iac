# Update ALB security group to allow CloudFront traffic
# resource "aws_security_group_rule" "alb_cloudfront" {
#   type        = "ingress"
#   from_port   = 80
#   to_port     = 80
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]  # CloudFront IPs change, so allow all
#   description = "Allow CloudFront to access ALB"
#   
#   security_group_id = var.alb_security_group_id
# }
