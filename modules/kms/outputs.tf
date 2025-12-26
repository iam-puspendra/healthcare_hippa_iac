output "cmk_arn" {
  value = aws_kms_key.cmk.arn
}

output "cmk_alias" {
  value = aws_kms_alias.cmk_alias.name
}
