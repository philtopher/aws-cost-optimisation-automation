/*output "policy_ids" {
  description = "Tag policy IDs"
  value       = aws_organizations_policy.tagging_policy.id
}*/
output "policy_ids" {
  description = "List of IDs of the tagging policies created"
  value       = [aws_organizations_policy.tagging_policy.id]
}

