output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.ad_server.id
}

output "public_ip" {
  description = "Public IP address of the AD server"
  value       = aws_instance.ad_server.public_ip
}

output "public_dns" {
  description = "Public DNS of the AD server"
  value       = aws_instance.ad_server.public_dns
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.ad_vpc.id
}

output "rdp_connection" {
  description = "RDP connection string"
  value       = "mstsc /v:${aws_instance.ad_server.public_ip}"
}