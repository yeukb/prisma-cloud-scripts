# Prisma Cloud Scripts
These are some sample scripts for Prisma Cloud.

## Usage
1. Update the "config" file with the necessary parameters
2. Install curl and jq if they are not already installed.

### get_account_groups
1. Run "*sh get_account_groups.sh*" or
       "*get_audit_logs_human_readable_date.sh*" or
       "*get_audit_logs_failed_result_only*"

### get_audit_logs
1. Update the **timeType**, **timeAmount** and **timeUnit** in the **get_audit_logs.sh** script
2. Run "*sh get_audit_logs.sh*"

### get_high_alerts_count_by_account_group
1. This script will aggregate the number of all open alerts with high severity PER ACCOUNT GROUP and output to a csv file in the format "account group,# of high alerts"
2. Update the **outputfile** in the **get_high_alerts_count_by_account_group.sh** script
3. Run "*get_high_alerts_count_by_account_group.sh*"
