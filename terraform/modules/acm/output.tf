output "certificate_arn" {
  description = "ARN of the requested ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "domain_validation_options" {
  description = "Domain validation options from ACM"
  value       = aws_acm_certificate.cert.domain_validation_options
}

output "dns_validation_records" {
  description = "CNAME records to add into your DNS registrar (Hostinger) for SSL verification"
  value = [
    for dvo in aws_acm_certificate.cert.domain_validation_options : {
      domain_name = dvo.domain_name
      cname_name  = dvo.resource_record_name
      cname_type  = dvo.resource_record_type
      cname_value = dvo.resource_record_value
    }
  ]
}
