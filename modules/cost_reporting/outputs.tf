output "budget_names" {
  description = "List of budgets created"
  value       = aws_budgets_budget.example.name
}
