output "public_ip" {
  value = aws_eip.hello_ip.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.hello_db.address
}

output "s3_bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}