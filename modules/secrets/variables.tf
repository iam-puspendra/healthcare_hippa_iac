variable "app_name" { default = "hipaa-app" }
variable "account_id" {}
variable "documentdb_endpoint" {}
variable "documentdb_username" { default = "mat_board_user" }
variable "documentdb_password" {}
variable "documentdb_database" { default = "1wellness" }
variable "stripe_secret_key" {}
variable "jwt_secret" { default = "fallback-jwt-secret-change-me" }


variable "client_url" { default = "http://hipaa-alb-2027346796.us-east-1.elb.amazonaws.com" }
variable "base_url" { default = "http://hipaa-alb-2027346796.us-east-1.elb.amazonaws.com/api" }
variable "smtp_email" { default = "expertweb634@gmail.com" }
variable "smtp_password" { default = "exeo qgdg ecdz rsjd" }
variable "smtp_host" { default = "smtp.gmail.com" }
variable "smtp_port" { default = "587" }
variable "s3_bucket_name" { default = "1wellness-data" }
variable "s3_region" { default = "us-east-1" }
variable "email_from" {default = "noreply@1wellness.com"}
variable "send_mail" { default = "1" }
variable "admin_mail_from" { default = "webexpert@yopmail.com" }
variable "order_confirm_mail_from" { default = "orders@1wellness.com" }
variable "admin_support_mail" { default = "webexpert@yopmail.com" }
variable "admin_email" { default = "admin@1wellness.com" }
variable "admin_access_token_expiry" { default = "15m" }
variable "admin_refresh_token_expiry" { default = "7d" }
variable "access_token_expiry" { default = "1m" }
variable "refresh_token_expiry" { default = "7d" }
