terraform {
  backend "s3" {
    bucket         = "orgname-terr-fir-pro-ap-south-1-20251007"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    use_lockfile   = true
  }
}
