# AWS-LifeCycle




# Terraform and Provider Definition

The script starts by defining the required version of the provider to use. Here, the AWS provider version is specified to be at least 4.9.0.

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
}
```

Then, it configures the provider to use the eu-north-1 region. You can replace this with any region you need.

```
provider "aws" {
  region  = "eu-north-1"
}
```

# IAM Role and Policy

Before creating the lifecycle policies, an IAM role is created that the lifecycle manager can assume. The policy associated with this role allows the lifecycle manager to perform necessary operations such as creating and deleting snapshots, and modifying snapshot and volume attributes.

```
resource "aws_iam_role" "example" {
  name = "example"
  ...
}

resource "aws_iam_role_policy" "example" {
  role   = aws_iam_role.example.id
  policy = data.aws_iam_policy_document.example.json
}

data "aws_iam_policy_document" "example" {
  statement {
    actions = [ ... ]
    resources = ["*"]
  }
}
```

# Lifecycle Policies

The script creates three lifecycle policies - daily, monthly, and weekly. Each policy is similar, with differences in the backup schedule and retention period.

Each lifecycle policy requires an execution role, the resource types to apply the policy to, a schedule for creating backups, a retention rule, and tags to add to the snapshots.

```
resource "aws_dlm_lifecycle_policy" "daily" {
  description        = "Daily DLM lifecycle policy"
  execution_role_arn = aws_iam_role.example.arn
  ...
}

resource "aws_dlm_lifecycle_policy" "monthly" {
  description        = "Monthly DLM lifecycle policy"
  execution_role_arn = aws_iam_role.example.arn
  ...
}

resource "aws_dlm_lifecycle_policy" "weekly" {
  description        = "Weekly DLM lifecycle policy"
  execution_role_arn = aws_iam_role.example.arn
  ...

}
```
