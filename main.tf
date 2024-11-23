terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
    }
  }
}

provider "aws" {
  region = var.region
}


# Data source for retrieving account details
#data "aws_organizations_organization" "org" {}

resource "aws_organizations_organizational_unit" "example" {
  name      = "example-ou"
  parent_id = var.parent_id
}

variable "parent_id" {
  description = "The ID of the parent organization"
  type        = string
}



# Cost Reporting Submodule
module "cost_reporting" {
  source = "./modules/cost_reporting"
  region = var.region
}

# Tagging Submodule
/*module "tagging" {
  source       = "./modules/tagging"
  organization = data.aws_organizations_organization.org
}*/

/*
module "tagging" {
  source     = "./modules/tagging"
  target_ids = var.organization_target_ids  # Pass the list of account or OU IDs
}
*/
/*module "tagging" {
  source     = "./modules/tagging"
  target_ids = var.organization_target_ids
}*/

module "tagging" {
  source     = "./modules/tagging"
  target_ids = var.organization_target_ids
}


/*variable "organization_target_ids" {
  description = "List of AWS account or OU IDs to attach the tagging policy"
  type        = list(string)
  default     = ["ou-xxxx-xxxxx", "account-id"] # Replace with your actual IDs
}*/

