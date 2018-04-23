variable "region" {
  description = "The aws region to use for S3 bucket."
  default = "us-west-2"
}

variable "bucket_name" {
  description = "1The name of the S3 bucket used to store terraform state. Must be globally unique."
  default = "km1.fabricator-pipeline.us-west-2"
}

variable "shared_credentials_file" {
  description = "Absolute path the AWS credentials file."
  default = "/Users/kashifmasood/.aws/credentials"
}

variable "aws_profile" {
  description = "AWS profile name referenced in the credentials file."
  default = "fabricator-pipeline"
}

variable "state_lock_table" {
  description = "Name of state lock table used for remote state management."
  default = "km.fabricator-pipeline-lock-table"
}
