This projects purpose is to provide a pipeline for a [Fabricator](http://fbrctr.github.io) based project.

The current foundation has the following resources/characteristics:

* 1 - VPC
* 1 - Internet Gateway
* 1 - Public Subnet
* 1 - Custom Route Table
* 1 - Custom Route (for internet access)
* 1 - Route Association (public subnet to custom route table)
* 1 - Security Groups (for web server)
* 3 - Security Group Rules
  * HTTP inbound (any IP)
  * SSH inbound (specific IP)
  * Anything outbound
* 1 - EC2 instance
* 1 - Elastic IP

## Pre-build Requirements

### AWSCLI

You will need to install the [AWSCLI](https://aws.amazon.com/cli/). It is highly recommended that you setup your home directory to support the AWSCLI tool as described [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html).

### Terraform

There are several ways to install Terraform. If you are a Homebrew user, I strongly encourage you to install Terraform as:

```
brew update
brew doctor
brew install terraform
```

### Terragrunt

This is an open sources free tool for managing Terraform configurations. There are several ways to install [Terragrunt](https://github.com/gruntwork-io/terragrunt). If you are a Homebrew user, I strongly encourage you to install it this way:

```
brew install terragrunt
```

## Build

### 1. Setup Remote State Management

You need to setup an S3 bucket that will be used to store Terraform state for each of the modules. This is a bit of a cart-horse thing since the S3 bucket setup is itself a module. In addition, because Terraform backend configuration doesn't allow any interpolation and Terragrunt configuration only allows function calls interpolation, this part is a little wonkie.

### 1.1 Manual Change Remote State Settings
```
cd <project_root_dir>
```

where 'project_root_dir' is the directory where you checked this source out to.

If you want to setup your own pipeline, then edit the root Terragrunt configuration file named 'terraform.tfvars' and change the following values:

* bucket - This value needs to be globally unique name.
  * Default: rig.fabricator-pipeline.us-west-2
* region - Even though the S3 buckets are global and not regional specific, you still have to supply a AWS region. Weird I know.
  * Default: us-west-2
* dynamodb_table - A unique table name that will be used to store the lock when making changes to remote state.
  * Default: fabricator-pipeline-lock-file.
* profile - A local AWS CLI profile name in your AWS credentials file.
  * Default: fabricator-pipeline

### 1.2 Setup S3 Bucket to Store Remote State
```
cd <project_root_dir>/global/s3
```

Run the Terragrunt apply to create the bucket which will also create the Dynamo DB table for you too.
```
terragrunt apply
```

You will be prompted to supply some input values.
* var.aws_profile - AWS profile name referenced in the credentials file.
  * Provide the same profile name you entered above in the root terraform.tfvars file.
* var.bucket_name - The name of the S3 bucket used to store terraform state. Must be globally unique.
  * Provide the same bucket name you entered above in the root terraform.tfvars file.
* var.shared_credentials_file - Absolute path the AWS credentials file.
  * Provide an absolute path to the AWS credentials file on your local workstation.
* var.state_lock_table - Name of state lock table used for remote state management.
  * Enter value: fabricator-pipeline-lock-table

If all goes well (no errors), you will be asked to confirm changes before it creates the S3 bucket. You need to enter 'yes' to proceed.

If this finishes successfully, you will see the ARN name of the S3 bucket in the output.

You can verify the S3 bucket by logging into the AWS console for digital-rig, going to the S3 console and then filtering by the bucket name. Inside the bucket should be folders for global and then s3 and in the s3 folder, you will see the terraform.tfstate file.

### 2. Setup Environment Infrastructure

Next you need to create all the Infrastructure (networking, routes, security, instance, etc...). This project creates a new VPC so everything is isolated and self contained.

### 2.1 Verify Integration Environment

You need to know your IP. You can get that IP address at [CheckIP](http://checkip.amazonaws.com). Once you have your IP, you need to build the infrastructure.

```
cd <project_root_dir>/integration/services/webserver
terragrunt plan
```

You will be prompted for the following information:
* Key pair name
  * Enter: <valid key pair name from region>
* Absolute path the AWS credentials file.
  * Provide an absolute path to the AWS credentials file on your local workstation
* SSH IP CIDR
  * Enter: <ip address from ckeckip>/32 or any other valid CIDR

If all is ok, proceed to the next step.

### 2.2 Build Integration Environment
```
terragrunt apply
```

### 3. Setup Nginx

Next you need to configure an nginx web server on the ec2 instance. This project is using Ansible for configuration management.

### 3.1 Run configuration

```
cd <project_root_dir>/ansible/playbook
ansible-playbook web-notls.yml
```

where 'project_root_dir' is the directory where you checked this source out to.
