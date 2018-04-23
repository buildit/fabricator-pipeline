variable "region" {
  description = "The aws region from which everything will be based on."
  default = "us-west-2"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block (i.e. 0.0.0.0/0)"
  default = "10.1.0.0/16"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  default = "km-fabricator-pipeline"
}

variable "environment" {
  description = "Either int, stg or prd"
  default = "int"
}

variable "shared_credentials_file" {
  description = "Absolute path the AWS credentials file."
  default = "/Users/kashifmasood/.aws/credentials"
}

variable "aws_profile" {
  description = "AWS profile name referenced in the credentials file."
  default = "fabricator-pipeline"
}

variable "public_subnet_cidr_block" {
  description = "Public Subnet CIDR block (i.e. 0.0.0.0/0)"
  default = "10.1.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "Public Subnet CIDR block (i.e. 0.0.0.0/0)"
  default = "10.1.2.0/24"
}

variable "ssh_cidr_block" {
  description = "SSH CIDR block (i.e. 0.0.0.0/0)"
  default = "208.184.53.0/24"
}

variable "key_pair_name" {
  description = "Existing key pair name in same region as the EC2 instance"
  default = "fabricator-key-pair-uswest2"
}

variable "codepipeline_bucket" {
  description = "The S3 bucket used by CodePipeline to store artifacts."
  default = "fabricator-artifact-bucket"
}

variable "git_owner" {
  description = "The ower of the Git repository where code will be pulled from."
  default = "buildit"
}

variable "git_repo" {
  description = "The Git repo name for this pipeline"
  default = "fabricator-assets"
}

variable "git_branch" {
  description = "The Git repo branch for this pipeline"
  default = "master"
}

variable "git_oauth_token" {
  description = "The Git OAuth token used to conect to the repo"
  default = "d9c142b4f6c619611d53c85aab423f84ef2de356"
}

