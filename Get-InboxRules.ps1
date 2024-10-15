# Import the Exchange Online module (install if not already installed)
# Install-Module -Name ExchangeOnlineManagement

# Prompt for the admin account's UserPrincipalName (UPN) to connect to Exchange Online
$AdminUPN = Read-Host -Prompt "Enter the admin UserPrincipalName (email address) to connect to Exchange Online"

# Connect to Exchange Online using the provided admin UPN
Connect-ExchangeOnline -UserPrincipalName $AdminUPN -ShowProgress $true

# Get all mailboxes in the tenant
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Loop through each mailbox to check their inbox rules
foreach ($mailbox in $mailboxes) {
    Write-Host "Checking inbox rules for user: $($mailbox.DisplayName)"

    try {
        # Get the user's inbox rules
        $inboxRules = Get-InboxRule -Mailbox $mailbox.UserPrincipalName
        
        # If the user has inbox rules, list them
        if ($inboxRules) {
            foreach ($rule in $inboxRules) {
                Write-Host " - Rule: " $rule.Name
                Write-Host "   Conditions: " $rule.Conditions
                Write-Host "   Actions: " $rule.Actions
            }
        } else {
            Write-Host " - No inbox rules found."
        }
    } catch {
        Write-Host " - Unable to retrieve inbox rules for $($mailbox.DisplayName). Error: $_"
    }
}

# Disconnect when done
Disconnect-ExchangeOnline
