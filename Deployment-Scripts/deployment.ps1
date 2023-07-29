#! /usr/bin/pwsh

$AzureDevOpsPAT = @($env:AzureDevOpsPAT)
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)"))}

$OrganizationName = @($env:OrganizationName)
$Projectid = @($env:Projectid)
$RelaseEnvName = @($env:selected_env)
$BranchName = @($env:BRANCH_NAME)
$Definitionids = @($env:releaseids -split ',')
$ReleaseDefs = @($env:releasedefs -split ',')
$counter = 0



Foreach ($defid in $Definitionids) { 

    Write-Color -Text "`r`n Release MS: ", "$($ReleaseDefs[$counter]) ", " | ENV: " ,"$RelaseEnvName" -Color Gray,Blue,Gray,Yellow
    
    
    # Step 1
    # Prompt User to continue on deployment or cancel release for the given release pipeline definition
    $answer = read-host -Prompt "`r`n Write 'Yes' to approve release or 'No' to reject"

    
    if ($answer -eq "Yes"){
        # Parse ("status" = "approved") to release approvement body
        $deploymentApprovementbody= @{
        "status" = "approved" #To Be Approved   
        }


        # Step 2
        # Get latest build number for the given micro-service definition to inform the user
        $requestBody_get = @{
        }
        $requestBodyJson_get = $requestBody_get | ConvertTo-Json

        $uri_get_laster_build_id = "https://dev.azure.com/$($OrganizationName)/$($Projectid)/_apis/build/latest/$($ReleaseDefs[$counter])?branchName=$($BranchName)&api-version=7.0-preview.1"
        $release_get_response = Invoke-RestMethod -Uri $uri_get_laster_build_id -Method get -body $requestBodyJson_get -Headers $AzureDevOpsAuthenicationHeader -ContentType 'application/json'

        $latest_build_hash = $release_get_response.buildNumber


