# AWS Cost Optimization Project

## <h1 id="introduction">Introduction</h1>
This repository provides Terraform modules for automating AWS cost reporting and enforcing tagging policies across AWS accounts or organizational units (OUs) within an AWS Organization. It helps users ensure compliance with organizational policies, manage AWS budgets effectively, and streamline resource tagging.

---

## <h1 id="features">Features</h1>
1. **Cost Reporting Module**:
   - Automates the creation of AWS Budgets for monitoring costs.
   - Filters budgets by service types such as `AmazonEC2`.

2. **Tagging Module**:
   - Creates and enforces AWS tagging policies using AWS Organizations.
   - Attaches tagging policies to multiple accounts or OUs for compliance.
   - Supports dynamic attachment of tagging policies using Terraform’s `for_each`.

---

## <h1 id="prerequisites">Prerequisites</h1>
- **Terraform** version `1.5.0+`
- AWS CLI installed and configured.
- IAM permissions for managing AWS Organizations, budgets, and EC2.

---

## <h1 id="directory-structure">Directory Structure</h1>
```markdown
aws-cost-tagging-automation/
├── main.tf                   # Root Terraform file to initialize modules
├── outputs.tf                # Root outputs for modules
├── variables.tf              # Root variable declarations
├── modules/
│   ├── cost_reporting/
│   │   ├── main.tf           # Handles AWS Budgets creation
│   │   ├── outputs.tf        # Outputs budget names
│   │   ├── variables.tf      # Variables for cost reporting module
│   ├── tagging/
│       ├── main.tf           # Creates tagging policy and attaches to targets
│       ├── outputs.tf        # Outputs tagging policy IDs
│       ├── variables.tf      # Variables for tagging module
```
<h1 id="usage">Usage</h1>
<h2 id="steps-to-deploy">Steps to Deploy</h2> <br>


Clone the Repository:

git clone https://github.com/your-repo/aws-cost-tagging-automation.git <br>
cd aws-cost-tagging-automation

Set Up Terraform:

Initialize Terraform providers:

terraform init

Validate the configuration:

terraform validate
Customize Variables:

Create a terraform.tfvars file in the root directory and define required variables:
```markdown
region = "us-east-1"
parent_id = "r-xxxx"  # AWS Organization root ID
organization_target_ids = ["ou-xxxx-xxxxx", "account-id"]  # Replace with actual target IDs
```
Apply the Configuration:

terraform apply
Review Outputs:

Upon successful deployment, Terraform will output:
Budget Names: Names of budgets created.
Tagging Policy IDs: IDs of tagging policies applied.
<h1 id="modules">Modules</h1>
<h2 id="cost-reporting-module">Cost Reporting Module</h2>
Purpose: Automates AWS Budgets creation for cost monitoring.
Files:
main.tf: Contains the logic to create an AWS budget.
outputs.tf: Outputs created budget names.
variables.tf: Defines required variables, such as the AWS region.

Example Resource
```markdown

resource "aws_budgets_budget" "example" {
  name         = "example-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "100"
  limit_unit   = "USD"

  cost_filter {
    name = "Service"
    values = [
      "AmazonEC2",
    ]
  }
}
```

<h2 id="tagging-module">Tagging Module</h2>
Purpose: Enforces tagging policies to ensure AWS resource compliance.
Files:
main.tf: Defines tagging policies and attaches them to accounts or OUs.
outputs.tf: Outputs IDs of applied tagging policies.
variables.tf: Defines required variables like target_ids.

Example Resources
```markdown

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

resource "aws_organizations_policy_attachment" "tagging_policy_attachment" {
  for_each = toset(var.target_ids)

  policy_id = aws_organizations_policy.tagging_policy.id
  target_id = each.value
}
```

<h1 id="inputs-and-outputs">Inputs and Outputs</h1>
<h2 id="inputs">Inputs</h2>
Name	Description	Type	Default
region	AWS region for resources	string	None
organization_target_ids	List of account or OU IDs where policies should apply	list(string)	None
<h2 id="outputs">Outputs</h2>
Name	Description
budget_names	List of AWS budget names created
tag_policies	List of IDs of tagging policies applied
<h1 id="notes">Notes</h1>
Ensure that your AWS account has AWS Organizations enabled.

The IAM user/role running Terraform must have permissions for:
Managing AWS Organizations (organizations:*).
Budget Management (budgets:*).
Modify terraform.tfvars as needed to customize target OUs/accounts and budget configurations.<br>

# Note: Before running the Github Actions workflow do the following:
1. Instead of requiring interactive input, provide a default value in the root variables.tf file with an example below:<br>
```markdown
variable "ou_ids" {
  type    = list(string)
  default = ["ou-example1", "ou-example2"] #default values, you can replace the ou-example.. with yours
  description = "List of OU IDs where policies should apply"
}
```

2. Alternatively, you can pass the variable value through an environment variable in the GitHub Actions workflow:<br>
```markdown
env:
  TF_VAR_ou_ids: '["ou-example1", "ou-example2"]'

```

3. If you run the workflow without doing No. 1 or 2 above the workflow will run indefintely because it will be waiting for input
<br>




# Below is an automated script that can automatically shut down unused resources after getting confirmation, scale down over-provisioned services, and recommend cost savings. This schedules the script to run at 9:00 AM on the first Monday of every two weeks.

```markdown

#!/bin/bash

WORK_DIR="/path/to/terraform/project"  # Replace with the actual path
EMAIL="admin@example.com"             # Replace with your email address
LOG_FILE="/tmp/terraform_execution.log"
LIFETIME_HOURS=6                      # Total lifetime of the resources
REMINDER_HOURS=4                      # When to send the reminder before destruction
DESTROY_DELAY=$((LIFETIME_HOURS - REMINDER_HOURS))

#Function to send an email notification
send_email() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$EMAIL"
}

#Function to check the last command's exit status
check_error() {
    if [ $? -ne 0 ]; then
        send_email "Terraform Automation Failed" \
            "An error occurred during the Terraform automation process. Check the log file at $LOG_FILE for details."
        echo "Terraform command failed. Exiting..." | tee -a "$LOG_FILE"
        exit 1
    fi
}

#Function to identify unused resources
identify_unused_resources() {
    echo "Identifying unused resources..." | tee -a "$LOG_FILE"
    # Add logic to identify unused resources (mock command for demonstration)
    UNUSED_RESOURCES=$(terraform show | grep "UnusedResource") 
    if [ -n "$UNUSED_RESOURCES" ]; then
        echo "Unused resources found:" | tee -a "$LOG_FILE"
        echo "$UNUSED_RESOURCES" | tee -a "$LOG_FILE"
        echo "Do you want to shut them down? (yes/no)"
        read -r CONFIRMATION
        if [ "$CONFIRMATION" == "yes" ]; then
            # Command to remove unused resources
            terraform destroy -target=<resource_identifier> -auto-approve >>"$LOG_FILE" 2>&1
            check_error
            echo "Unused resources have been shut down." | tee -a "$LOG_FILE"
        else
            echo "No action taken on unused resources." | tee -a "$LOG_FILE"
        fi
    else
        echo "No unused resources detected." | tee -a "$LOG_FILE"
    fi
}

#Function to scale down over-provisioned services
scale_down_services() {
    echo "Scaling down over-provisioned services..." | tee -a "$LOG_FILE"
    # Add logic to scale down services (mock command for demonstration)
    terraform apply -var="scale=down" -auto-approve >>"$LOG_FILE" 2>&1
    check_error
    echo "Over-provisioned services have been scaled down." | tee -a "$LOG_FILE"
}

#Function to recommend cost savings
recommend_cost_savings() {
    echo "Recommending cost savings..." | tee -a "$LOG_FILE"
    # Add logic to analyze resources and suggest savings
    terraform show | grep "CostRecommendation" >>"$LOG_FILE" 2>&1
    echo "Cost savings recommendations have been logged." | tee -a "$LOG_FILE"
    send_email "Cost Savings Recommendations" \
        "Terraform automation has identified cost-saving opportunities. Check the log file at $LOG_FILE for details."
}

#Main script
echo "Starting Terraform Automation..." | tee "$LOG_FILE"

#Navigate to the Terraform project directory
cd "$WORK_DIR" || {
    send_email "Terraform Automation Failed" "Unable to access Terraform project directory: $WORK_DIR"
    echo "Failed to change directory to $WORK_DIR. Exiting..." | tee -a "$LOG_FILE"
    exit 1
}

#Initialize Terraform
echo "Initializing Terraform..." | tee -a "$LOG_FILE"
terraform init >>"$LOG_FILE" 2>&1
check_error

#Validate Terraform configuration
echo "Validating Terraform configuration..." | tee -a "$LOG_FILE"
terraform validate >>"$LOG_FILE" 2>&1
check_error

#Plan Terraform changes
echo "Planning Terraform changes..." | tee -a "$LOG_FILE"
terraform plan -out=tfplan >>"$LOG_FILE" 2>&1
check_error

#Apply Terraform plan
echo "Applying Terraform changes..." | tee -a "$LOG_FILE"
terraform apply -auto-approve tfplan >>"$LOG_FILE" 2>&1
check_error

#Call functions for additional tasks
identify_unused_resources
scale_down_services
recommend_cost_savings

#Notify user of resource provisioning
send_email "Terraform Resources Provisioned" \
    "Terraform automation has provisioned resources successfully. These resources will be destroyed in $LIFETIME_HOURS hours. Reminder will be sent in $DESTROY_DELAY hours."

#Wait for the reminder period
echo "Waiting for $REMINDER_HOURS hours before sending reminder..." | tee -a "$LOG_FILE"
sleep "${REMINDER_HOURS}h"

#Send reminder email
send_email "Resource Destruction Reminder" \
    "Reminder: Resources provisioned by Terraform will be destroyed in $DESTROY_DELAY hours."

#Wait for the remaining period before destruction
echo "Waiting for $DESTROY_DELAY hours before destroying resources..." | tee -a "$LOG_FILE"
sleep "${DESTROY_DELAY}h"

#Destroy Terraform resources
echo "Destroying Terraform resources..." | tee -a "$LOG_FILE"
terraform destroy -auto-approve >>"$LOG_FILE" 2>&1
check_error

#Notify user of successful destruction
send_email "Terraform Resources Destroyed" \
    "Terraform automation has successfully destroyed the resources after $LIFETIME_HOURS hours."

echo "Terraform automation completed successfully." | tee -a "$LOG_FILE"
```

# Further explanations:

# 1. Unused Resources:

Identifies unused resources using terraform show (replace with actual logic based on your setup).
Prompts for user confirmation before removing them.

# 2. Scaling Down Services:

Mock command demonstrates the use of a variable (scale=down) to trigger scaling changes. Replace it with your actual logic.

# 3. Cost Savings Recommendations:

Analyzes the Terraform state to identify cost-saving opportunities and logs them.

# 4. Error Handling:

Stops the process and sends an email if any command fails.

# 5. Lifecycle Management:

Ensures resources are shut down after a set lifetime with proper notifications.</h3><br>

# How to Contribute
Contributions are welcome! Please fork the repository, make your changes, and create a pull request.

# License
This project is licensed under the MIT License.

# Contact

For questions or support, contact tufort-facebk@yahoo.co.uk
