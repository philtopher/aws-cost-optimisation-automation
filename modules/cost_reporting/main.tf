# Create Cost Explorer
resource "aws_budgets_budget" "example" {
  name         = "example-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "100"
  limit_unit   = "USD"

  /*filter {
    dimensions = {
      Key = "SERVICE"
      Value = "AmazonEC2"
    }
  }*/

  cost_filter {
    name = "Service"
    values = [
      "AmazonEC2",
    ]
  }
}


# Output budget names. 
/*output "budget_names" {
  value = [aws_budgets_budget.example.name]
}*/#Already declared in main.tf
