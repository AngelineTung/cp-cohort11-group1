terraform {
  backend "s3" {
    bucket         = "ce11-grp1-capstone-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ce11-grp1-capstone-tf-lock"
    encrypt        = true
  }
}
