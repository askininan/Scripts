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
