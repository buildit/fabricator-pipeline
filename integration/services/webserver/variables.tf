variable "region" {
  description = "The aws region from which everything will be based on."
  default = "us-west-2"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block (i.e. 0.0.0.0/0)"
}

variable "public_subnet_cidr_block" {
  description = "Public Subnet CIDR block (i.e. 0.0.0.0/0)"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "environment" {
  description = "Either int, stg or prd"
}

variable "shared_credentials_file" {
  description = "Absolute path the AWS credentials file."
}

variable "aws_profile" {
  description = "AWS profile name referenced in the credentials file."
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
}
