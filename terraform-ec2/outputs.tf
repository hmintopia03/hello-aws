output "public_ip" {
  value = aws_eip.hello_ip.public_ip
}