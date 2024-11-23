/*variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}*/

variable "region" {
  description = "AWS region to use"
  type        = string
}

variable "organization_target_ids" {
  description = "List of account or OU IDs where policies should apply"
  type        = list(string)
}
