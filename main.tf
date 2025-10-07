data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Official Canonical (Ubuntu) owner ID


  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

  resource "aws_instance" "example" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  tags = {
    Name = "HelloWorld"
  }
}

# KMS key for SSE-KMS (optional; S3-managed AES256 is simpler)
data "aws_caller_identity" "current" {}

resource "aws_kms_key" "s3" {
  description             = "S3 bucket object encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowAccountAdmin",
        Effect: "Allow",
        Principal: { AWS: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
        Action: "kms:*",
        Resource: "*"
      },
      {
        Sid: "AllowS3UseOfKMSKey",
        Effect: "Allow",
        Principal: { Service: "s3.amazonaws.com" },
        Action: [
          "kms:Encrypt","kms:Decrypt","kms:ReEncrypt*","kms:GenerateDataKey*","kms:DescribeKey"
        ],
        Resource: "*"
      }
    ]
  })
}


resource "aws_s3_bucket" "this" {
  bucket = "orgname-terr-fir-pro-ap-south-1-20251007"
  tags = {
    Name        = "app-bucket"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_s3" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}

