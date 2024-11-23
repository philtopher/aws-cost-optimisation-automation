/*resource "aws_resource_tag" "example" {
  resource_id = aws_instance.example.id
  tags = {
    Environment = "Production"
    Team        = "DevOps"
  }
}*/
/*
resource "aws_organizations_policy" "tagging_policy" {
  name        = "TaggingPolicy"
  description = "Enforces tagging policies across accounts"
  content     = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:RequestTag/CostCenter": "12345"
        }
      },
      "Resource": "*"
    }
  ]
}
EOT

  # If targeting specific OUs or accounts, attach here
  target_ids = var.target_ids
}*/

resource "aws_organizations_policy" "tagging_policy" {
  name        = "TaggingPolicy"
  description = "Enforces tagging policies across accounts"
  content     = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:RequestTag/CostCenter": "12345"
        }
      },
      "Resource": "*"
    }
  ]
}
EOT
}

# Attach policy to target accounts or OUs
resource "aws_organizations_policy_attachment" "tagging_policy_attachment" {
  for_each = toset(var.target_ids)

  policy_id = aws_organizations_policy.tagging_policy.id
  target_id = each.value
}




