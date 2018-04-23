resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "${var.project_name}-codebuild-policy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterfacePermission",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "s3:CreateBucket",
        "s3:GetObject",
        "s3:List*",
        "s3:PutObject"
      ]
    },
    {
       "Effect": "Allow",
       "Action": [
         "s3:GetObject"
       ],
       "Resource": ["arn:aws:s3:::fabaricator-support/*"]
     }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "${var.project_name}-codebuild-policy-attachment"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "codebuild-project" {
  name         = "${var.project_name}-codebuild-project"
  description  = "${var.project_name}-codebuild-project"
  build_timeout      = "5"
  service_role = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
    packaging = "ZIP"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:6.3.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "WEB_SERVER_IP"
      "value" = "${var.web_server_ip}"
    }
  }

  source {
    type     = "CODEPIPELINE"

//    type     = "GITHUB"
//    location = "https://github.com/buildit/fabricator-assets.git"

    // Make sure to add instructions to manually connect aws with github (via the web ui) prior to running this script
//    auth {
//      type = "OAUTH"
//    }
  }

  vpc_config {
    vpc_id = "${var.VPC_ID}"

    subnets = [
      "${var.VPC_Private_Subnet_ID}"
    ]

    security_group_ids = [
      "${var.VPC_Security_Group_ID}"
    ]
  }
}
