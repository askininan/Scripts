#! /usr/bin/pwsh

[CmdletBinding()]
param(  
    
    [Parameter(Mandatory=$true)]
    [string]$release_branch,

    [Parameter(Mandatory=$true)]
    [string]$targetEnv,
    
    [Parameter(Mandatory=$true)]
    [string]$sourceEnv,

    [Parameter(Mandatory=$false)]
    [alias('auto')]
    [switch]$auto_flow
)


##### UTILITY FUNCTIONS #####

# Invoke Azure Devops API release URI
function Invoke_AZ_API{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Add_URI,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $METHOD,
        [Parameter(Mandatory=$false, Position=2)]
        [string] $requestBody
    )

    $AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)"))}
    $uri = "$($AZBaseURL)$($Add_URI)"
    Invoke-RestMethod -Uri $uri -Method $METHOD -body $requestBody -Headers $AzureDevOpsAuthenicationHeader -ContentType 'application/json' -ErrorAction SilentlyContinue
}