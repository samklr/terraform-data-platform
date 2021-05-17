resource "aws_iam_role" "instance_role" {
  name = "emr-instance-role-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "service_role" {
  name = "emr-cluster-service-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "elasticmapreduce.amazonaws.com",
            "glue.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "autoscaling_role" {
  name = "emr-cluster-autoscaling-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "application-autoscaling.amazonaws.com",
          "elasticmapreduce.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "service_role_base" {
  name = "emr-service-base-${var.environment}"
  role = aws_iam_role.service_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "ec2:*",
                "iam:GetRole",
                "iam:PutRole",
                "iam:GetRolePolicy",
                "iam:PutRolePolicy",
                "iam:ListInstanceProfiles",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "s3:CreateBucket",
                "s3:Get*",
                "s3:List*",
                "s3:Put*",
                "sdb:BatchPutAttributes",
                "sdb:Select",
                "sqs:*",
                "cloudwatch:*",
                "application-autoscaling:RegisterScalableTarget",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:Describe*",
                "glue:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "spot.amazonaws.com"
                }
            }
        }
    ]
}
EOF

}

resource "aws_iam_role_policy" "instance_profile_base" {
  name = "emr-generic-policy-${var.environment}"
  role = aws_iam_role.instance_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "cloudwatch:*",
                "ec2:Describe*",
                "elasticmapreduce:*"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": "arn:aws:ssm:*:${var.aws_account_id}:parameter/*",
            "Action": [ "ssm:GetParameter", "ssm:SetParameter"]
        },
          {
            "Effect": "Allow",
            "Resource": [
              "arn:aws:glue:${var.region}:${var.aws_account_id}:catalog",
              "arn:aws:glue:${var.region}:${var.aws_account_id}:database/*",
              "arn:aws:glue:${var.region}:${var.aws_account_id}:table/*"
            ],
            "Action": [ "glue:*" ]
          },
        {
            "Effect": "Allow",
            "Action": ["s3:*"],
            "Resource": [
                "arn:aws:s3:::${var.datalake_s3_bucket}/*",
                "arn:aws:s3:::${var.datalake_s3_bucket}"
              ]
        }
    ]
}
EOF

}

resource "aws_iam_role_policy" "autoscaling_base" {
  name = "emr-cluster-autoscaling-base-${var.environment}"
  role = aws_iam_role.autoscaling_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:DescribeAlarms",
                "elasticmapreduce:ListInstanceGroups",
                "elasticmapreduce:ModifyInstanceGroups"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "emr_instance_profile" {
  name = "emr-cluster-instance-profile-${var.environment}"
  role = aws_iam_role.instance_role.id
}
