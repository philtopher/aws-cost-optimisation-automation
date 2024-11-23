#!/bin/bash

# Configuration
WORK_DIR="/path/to/terraform/project"  # Replace with the actual path
EMAIL="admin@example.com"             # Replace with your email address
LOG_FILE="/tmp/terraform_execution.log"
LIFETIME_HOURS=6                      # Total lifetime of the resources
REMINDER_HOURS=4                      # When to send the reminder before destruction
DESTROY_DELAY=$((LIFETIME_HOURS - REMINDER_HOURS))

# Function to send an email notification
send_email() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$EMAIL"
}

# Function to check the last command's exit status
check_error() {
    if [ $? -ne 0 ]; then
        send_email "Terraform Automation Failed" \
            "An error occurred during the Terraform automation process. Check the log file at $LOG_FILE for details."
        echo "Terraform command failed. Exiting..." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Function to identify unused resources
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

# Function to scale down over-provisioned services
scale_down_services() {
    echo "Scaling down over-provisioned services..." | tee -a "$LOG_FILE"
    # Add logic to scale down services (mock command for demonstration)
    terraform apply -var="scale=down" -auto-approve >>"$LOG_FILE" 2>&1
    check_error
    echo "Over-provisioned services have been scaled down." | tee -a "$LOG_FILE"
}

# Function to recommend cost savings
recommend_cost_savings() {
    echo "Recommending cost savings..." | tee -a "$LOG_FILE"
    # Add logic to analyze resources and suggest savings
    terraform show | grep "CostRecommendation" >>"$LOG_FILE" 2>&1
    echo "Cost savings recommendations have been logged." | tee -a "$LOG_FILE"
    send_email "Cost Savings Recommendations" \
        "Terraform automation has identified cost-saving opportunities. Check the log file at $LOG_FILE for details."
}

# Main script
echo "Starting Terraform Automation..." | tee "$LOG_FILE"

# Navigate to the Terraform project directory
cd "$WORK_DIR" || {
    send_email "Terraform Automation Failed" "Unable to access Terraform project directory: $WORK_DIR"
    echo "Failed to change directory to $WORK_DIR. Exiting..." | tee -a "$LOG_FILE"
    exit 1
}

# Initialize Terraform
echo "Initializing Terraform..." | tee -a "$LOG_FILE"
terraform init >>"$LOG_FILE" 2>&1
check_error

# Validate Terraform configuration
echo "Validating Terraform configuration..." | tee -a "$LOG_FILE"
terraform validate >>"$LOG_FILE" 2>&1
check_error

# Plan Terraform changes
echo "Planning Terraform changes..." | tee -a "$LOG_FILE"
terraform plan -out=tfplan >>"$LOG_FILE" 2>&1
check_error

# Apply Terraform plan
echo "Applying Terraform changes..." | tee -a "$LOG_FILE"
terraform apply -auto-approve tfplan >>"$LOG_FILE" 2>&1
check_error

# Call functions for additional tasks
identify_unused_resources
scale_down_services
recommend_cost_savings

# Notify user of resource provisioning
send_email "Terraform Resources Provisioned" \
    "Terraform automation has provisioned resources successfully. These resources will be destroyed in $LIFETIME_HOURS hours. Reminder will be sent in $DESTROY_DELAY hours."

# Wait for the reminder period
echo "Waiting for $REMINDER_HOURS hours before sending reminder..." | tee -a "$LOG_FILE"
sleep "${REMINDER_HOURS}h"

# Send reminder email
send_email "Resource Destruction Reminder" \
    "Reminder: Resources provisioned by Terraform will be destroyed in $DESTROY_DELAY hours."

# Wait for the remaining period before destruction
echo "Waiting for $DESTROY_DELAY hours before destroying resources..." | tee -a "$LOG_FILE"
sleep "${DESTROY_DELAY}h"

# Destroy Terraform resources
echo "Destroying Terraform resources..." | tee -a "$LOG_FILE"
terraform destroy -auto-approve >>"$LOG_FILE" 2>&1
check_error

# Notify user of successful destruction
send_email "Terraform Resources Destroyed" \
    "Terraform automation has successfully destroyed the resources after $LIFETIME_HOURS hours."

echo "Terraform automation completed successfully." | tee -a "$LOG_FILE"
