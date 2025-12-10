output "bucket_name" {
  value = aws_s3_bucket.iot_raw_data.bucket
}

output "iot_s3_role_arn" {
  value = aws_iam_role.iot_s3_role.arn
}
