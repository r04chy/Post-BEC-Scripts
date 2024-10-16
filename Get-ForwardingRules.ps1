# Import Exchange Online PowerShell Module (if not already imported)
Import-Module ExchangeOnlineManagement

# Prompt for the UPN to connect with
$adminUPN = Read-Host "Please enter the UPN of the admin account"

# Connect to Exchange Online using the provided UPN
Connect-ExchangeOnline -UserPrincipalName $adminUPN

# Get all mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Initialize array to store forwarding rules
$forwardingRules = @()

# Loop through each mailbox to get inbox rules
foreach ($mailbox in $mailboxes) {
    $rules = Get-InboxRule -Mailbox $mailbox.UserPrincipalName

    # Filter for rules that forward mail
    $forwardRules = $rules | Where-Object {
        $_.ForwardTo -or $_.RedirectTo
    }

    # Store each forwarding rule with the mailbox information
    foreach ($rule in $forwardRules) {
        $forwardingRules += [pscustomobject]@{
            Mailbox       = $mailbox.UserPrincipalName
            RuleName      = $rule.Name
            ForwardTo     = ($rule.ForwardTo | ForEach-Object { $_.Name }) -join ", "
            RedirectTo    = ($rule.RedirectTo | ForEach-Object { $_.Name }) -join ", "
        }
    }
}

# Output the forwarding rules
$forwardingRules | Format-Table -AutoSize

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
