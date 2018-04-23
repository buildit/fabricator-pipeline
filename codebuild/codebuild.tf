resource "aws_s3_bucket" "km-fabricator-bucket" {
  bucket = "km-fabricator-bucket"
  acl    = "private"
}

resource "aws_iam_role" "km-fabricator-codebuild_role" {
  name = "codebuild-role-"

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

resource "aws_iam_policy" "km-fabricator-codebuild_policy" {
  name        = "codebuild-policy"
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
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment"
  policy_arn = "${aws_iam_policy.km-fabricator-codebuild_policy.arn}"
  roles      = ["${aws_iam_role.km-fabricator-codebuild_role.id}"]
}

resource "aws_codebuild_project" "foo" {
  name         = "km-fabricator-project"
  description  = "km-fabricator_codebuild_project"
  build_timeout      = "5"
  service_role = "${aws_iam_role.km-fabricator-codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.km-fabricator-bucket.bucket}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:6.3.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "SOME_KEY2"
      "value" = "SOME_VALUE2"
    }
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/buildit/fabricator-assets"
    auth {
      type = "OAUTH"
      resource = "d9c142b4f6c619611d53c85aab423f84ef2de356"
    }

  }

  vpc_config {
    vpc_id = "vpc-201cb845"

    subnets = [
      "subnet-b2d66fd7"
    ]

    security_group_ids = [
      "sg-84b4a2e1"
    ]
  }

  tags {
    "Environment" = "Stage"
  }
}
