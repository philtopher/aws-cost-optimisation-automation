/*variable "organization" {
  description = "AWS Organization data"
  type        = object({
    root_id = string
  })
}*/

/*variable "target_ids" {
  description = "List of AWS account or OU IDs where the policy will be applied"
  type        = list(string)
}
*/
/*variable "target_ids" {
  description = "List of AWS account or OU IDs where the tagging policy will be applied"
  type        = list(string)
}*/

variable "target_ids" {
  description = "List of AWS account or OU IDs to attach the tagging policy"
  type        = list(string)
}


