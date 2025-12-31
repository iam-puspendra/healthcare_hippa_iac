resource "aws_secretsmanager_secret" "app_secrets" {
  name = "${var.app_name}/app-secrets"
  description = "HIPAA-compliant application secrets (DocumentDB + Stripe + JWT)"
  recovery_window_in_days = 7  # HIPAA audit requirement
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    # DocumentDB
    MONGO_URI      = "mongodb://${var.documentdb_username}:${var.documentdb_password}@${var.documentdb_endpoint}/${var.documentdb_database}?authSource=admin"
    DB_USERNAME    = var.documentdb_username
    DB_PASSWORD    = var.documentdb_password
    DB_HOST        = var.documentdb_endpoint
    DB_NAME        = var.documentdb_database
    
    # Stripe (HIPAA Payment Processing)
    STRIPE_SECRET_KEY = var.stripe_secret_key
    
    # Auth
    JWT_SECRET             = var.jwt_secret
    ADMIN_ACCESS_TOKEN_EXPIRY   = var.admin_access_token_expiry
    ADMIN_REFRESH_TOKEN_EXPIRY  = var.admin_refresh_token_expiry
    ACCESS_TOKEN_EXPIRY         = var.access_token_expiry
    REFRESH_TOKEN_EXPIRY        = var.refresh_token_expiry
    
    # App Config
    NODE_ENV  = "production"
    PORT      = "3001"
    CLIENT_URL = var.client_url
    BASE_URL  = var.base_url
    
    # Email (SMTP)
    SMTP_EMAIL        = var.smtp_email
    SMTP_PASSWORD     = var.smtp_password
    SMTP_HOST         = var.smtp_host
    SMTP_PORT         = var.smtp_port
    EMAIL_FROM        = var.email_from
    SEND_MAIL         = var.send_mail
    ADMIN_MAIL_FROM   = var.admin_mail_from
    ORDER_CONFIRM_MAIL_FROM = var.order_confirm_mail_from
    ADMIN_SUPPORT_MAIL = var.admin_support_mail
    ADMIN_EMAIL       = var.admin_email
    
    # S3
    S3_BUCKET_NAME    = var.s3_bucket_name
    S3_REGION         = var.s3_region 
  })
}






