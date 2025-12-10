############################################
# S3 Bucket for IoT Raw Data
############################################

resource "aws_s3_bucket" "iot_raw_data" {
  bucket = "${var.environment}-iot-simulator-raw-data"

  force_destroy = true

  tags = merge(
    var.tags,
    {
      Component = "IoTStorage"
      Purpose   = "RawTelemetry"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "iot_raw_data" {
  bucket = aws_s3_bucket.iot_raw_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


############################################
# IAM Role for IoT -> S3 write
############################################

resource "aws_iam_role" "iot_s3_role" {
  name = "${var.environment}-iot-s3-writer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "iot.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "iot_s3_policy" {
  name = "${var.environment}-iot-s3-write-policy"
  role = aws_iam_role.iot_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.iot_raw_data.arn}/*"
      }
    ]
  })
}


############################################
# IoT Topic Rule -> S3
############################################

resource "aws_iot_topic_rule" "simulator_to_s3" {
  name        = "${var.environment}-simulator-to-s3"
  description = "Store IoT Simulator messages in S3"
  enabled     = true

  # Matches topics like: iot/simulator/device123/data
  sql         = "SELECT *, topic() AS topic FROM 'iot/simulator/+/data'"
  sql_version = "2016-03-23"

  s3 {
    bucket_name = aws_s3_bucket.iot_raw_data.bucket
    key         = "${topic()}/${timestamp()}.json"
    role_arn    = aws_iam_role.iot_s3_role.arn
  }

  tags = var.tags
}
