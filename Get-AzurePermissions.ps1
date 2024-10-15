# Import Microsoft Graph module
Import-Module Microsoft.Graph

# Connect to Microsoft Graph with appropriate permissions
Connect-MgGraph -Scopes "Directory.Read.All", "RoleManagement.Read.Directory"

# Get all admin roles in the tenant
$adminRoles = Get-MgDirectoryRole

# Create a hash table to store user roles
$userRoleMapping = @{}

# Loop through each role to get members and their roles
foreach ($role in $adminRoles) {
    Write-Host "Role: " $role.DisplayName
    $roleMembers = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
    foreach ($member in $roleMembers) {
        # Check if the user is already in the hash table
        if (-not $userRoleMapping.ContainsKey($member.Id)) {
            $userRoleMapping[$member.Id] = @()
        }

        # Add the role to the user's list of roles
        $userRoleMapping[$member.Id] += $role.DisplayName
    }
}

# Now get the details of all users with roles
foreach ($userId in $userRoleMapping.Keys) {
    $user = Get-MgUser -UserId $userId
    $roles = $userRoleMapping[$userId] -join ", "
    Write-Host "User: " $user.DisplayName " | Roles: " $roles
}

# Disconnect when done
Disconnect-MgGraph
