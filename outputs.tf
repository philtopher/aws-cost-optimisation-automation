output "budget_names" {
  description = "Names of created budgets"
  value       = module.cost_reporting.budget_names
}

output "tag_policies" {
  description = "Applied tag policies"
  value       = module.tagging.policy_ids
}
