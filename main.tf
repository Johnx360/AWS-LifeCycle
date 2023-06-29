terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
}

provider "aws" {
  region  = "eu-north-1" # or any other region
}

# Now define the resources for lifecycle manager
# Daily backup
resource "aws_dlm_lifecycle_policy" "daily" {
  description        = "Daily DLM lifecycle policy"
  execution_role_arn = aws_iam_role.example.arn

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily backup schedule"
      
      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        Lifecycle = "Daily Backup"
      }
      
      copy_tags = false
    }

    target_tags = {
      Lifecycle = "Daily Backup"
    }
  }

  depends_on = [aws_iam_role_policy.example]
}

# Monthly backup
resource "aws_dlm_lifecycle_policy" "monthly" {
  description        = "Monthly DLM lifecycle policy"
  execution_role_arn = aws_iam_role.example.arn

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Monthly backup schedule"
      
      create_rule {
        cron_expression = "cron(0 0 1 * ? *)" # Runs at 00:00 on day-of-month 1
      }

      retain_rule {
        count = 2
      }

      tags_to_add = {
        Lifecycle = "Monthly Backup"
      }
      
      copy_tags = false
    }

    target_tags = {
      Lifecycle = "Monthly Backup"
    }
  }

  depends_on = [aws_iam_role_policy.example]
}

# Weekly backup
resource "aws_dlm_lifecycle_policy" "weekly" {
  description        = "Weekly DLM lifecycle policy"
  execution_role_arn = aws_iam_role.example.arn

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Weekly backup schedule"
      
      create_rule {
        cron_expression = "cron(0 0 ? * SUN *)" # Runs at 00:00 on Sunday
      }

      retain_rule {
        count = 4
      }

      tags_to_add = {
        Lifecycle = "Weekly Backup"
      }
      
      copy_tags = false
    }

    target_tags = {
      Lifecycle = "Weekly Backup"
    }
  }

  depends_on = [aws_iam_role_policy.example]
}

resource "aws_iam_role" "example" {
  name = "example"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "dlm.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "example" {
  role   = aws_iam_role.example.id
  policy = data.aws_iam_policy_document.example.json
}

data "aws_iam_policy_document" "example" {
  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "iam:CreateServiceLinkedRole",
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "ec2:ModifySnapshotAttribute",
      "ec2:CopySnapshot",
      "ec2:ModifySnapshot",
      "ec2:ModifyVolumeAttribute"
    ]

    resources = ["*"]
  }
}
