# Get Microsoft 365 All Users Information 
# Ref: https://learn.microsoft.com/en-us/powershell/module/msonline/get-msoluser?view=azureadps-1.0
C:
cd \pwsh7\1.results

# Define global variables
$_Dte = Get-Date -Format "yyyyMMdd"
$_allUsersSet = @()

# Install and import MsOnline, AzureADPreview, Microsoft.Graph PowerShell modules
$PSVersionTable.PSVersion
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Get-ExecutionPolicy -List

Install-Module -Name MsOnline -Scope CurrentUser -Force
Import-Module -Name MsOnline
#Install-Module -Name AzureADPreview -AllowClobber -Scope CurrentUser -Force
#Import-Module -Name AzureADPreview
Install-Module -Name Microsoft.Graph.Users -Scope CurrentUser -Force
Import-Module -Name Microsoft.Graph.Users
Install-Module -Name Microsoft.Graph.Reports -Scope CurrentUser -Force
Import-Module -Name Microsoft.Graph.Reports

#Connect to Microsoft Online Service
Connect-MsolService
# Connect to Microsoft Graph with the required permissions
Connect-MgGraph -Scopes "AuditLog.Read.All"

# Retrieve all users and their properties
$users = Get-MgUser -All -Property 'UserPrincipalName','SignInActivity', 'lastPasswordChangeDateTime', 'DisplayName', 'Mail', 'AccountEnabled', 'givenName', 'surname', 'department', 'UserType', 'Id'

# Define the date range for sign-in logs (last 30 days)
$dateRange = (Get-Date).AddDays(-30)

# Loop through each user and output their properties
$results = foreach ($user in $users) {
    # Retrieve user properties
    $userOutput = $user | Select-Object DisplayName, UserPrincipalName, Mail, lastPasswordChangeDateTime, AccountEnabled, givenName, surname, department, UserType, Id

    # Retrieve sign-in logs for the user in the last month
    $signInLogs = Get-MgAuditLogSignIn -All -Filter "userPrincipalName eq '$($user.UserPrincipalName)' and createdDateTime ge $($dateRange.ToString('yyyy-MM-ddTHH:mm:ssZ'))" | Sort-Object -Property createdDateTime -Descending

    if ($signInLogs) {
        $lastSignIn = $signInLogs[0].CreatedDateTime.AddHours(-4).ToString("MMM dd, yyyy, h:mm tt")
    } else {
        $lastSignIn = "None"
    }

    # Output user properties
    [PSCustomObject]@{
        DisplayName            = $userOutput.DisplayName
        UserPrincipalName      = $userOutput.UserPrincipalName
        Email                  = $userOutput.Mail
        LastSignInWithin30Days = $lastSignIn
        LastPasswordChange     = $userOutput.lastPasswordChangeDateTime
        AccountEnabled         = $userOutput.AccountEnabled
        givenName              = $userOutput.givenName
        surname                = $userOutput.surname
        department             = $userOutput.department
        UserType               = $userOutput.UserType
        ObjectId               = $userOutput.Id
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\pwsh7\1.results\user_properties.$_Dte.csv" -NoTypeInformation
