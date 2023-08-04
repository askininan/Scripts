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


        # Step 3
        # Input build hash
        DO {$build_hash = read-host -prompt "`r`n Latest Build No: $latest_build_hash | Input your build number"

            $requestBody_get = @{
            }
            $requestBodyJson_get = $requestBody_get | ConvertTo-Json

            $uri_get_build_id = "https://dev.azure.com/$($OrganizationName)/$($Projectid)/_apis/build/builds?buildNumber=$($build_hash)&api-version=7.0"
            $release_get_response = Invoke-RestMethod -Uri $uri_get_build_id -Method get -body $requestBodyJson_get -Headers $AzureDevOpsAuthenicationHeader -ContentType 'application/json' 


            $response_filter_definition = $release_get_response.value | where { ($_.definition.name -eq $($ReleaseDefs[$counter]))}
            $build_id = $response_filter_definition.id 

        } While ([string]::IsNullOrEmpty($build_id))


        Write-Color -Text "`r`n Approval: ", "Approved `r`n" -Color Gray,Green

    }else {
        Write-Color -Text "`r`n Release MS : ", "$($ReleaseDefs[$counter]) ", " | ENV : " ," $RelaseEnvName ", " | Status: ", "Cancelled `r`n" -Color Gray,Blue,Gray,Yellow,Gray,Red
        $counter += 1
        "-"*100 | Write-Host
        continue
    }

    # Step 4
    # Create Release by Azure CLI command for the given release definition and build hash
    $release_response = az pipelines release create --org https://dev.azure.com/$OrganizationName --project $Projectid --definition-id=$defid --artifact-metadata-list "$($ReleaseDefs[$counter])=$($build_id)" | ConvertFrom-Json
    $counter += 1

    # Get release ID
    $Releaseid = $release_response.id 

    # Get release environment(stage) ID of the desired deployment environment(stage)
    foreach($env in $release_response.environments) {if ($env.name -eq $RelaseEnvName) { $env_id = $env.id}}

    # Step 5
    # Patch to deploy to desired environment(stage)
    $requestBody_patch = @{
        "status"= "inProgress";
        }
    $requestBodyJson_patch = $requestBody_patch | ConvertTo-Json

    $uri_patch_stage = "https://vsrm.dev.azure.com/$($OrganizationName)/$($Projectid)/_apis/release/releases/$($Releaseid)/environments/$($env_id)?api-version=7.0"
    $release_patch_response = Invoke-RestMethod -Uri $uri_patch_stage -Method patch -body $requestBodyJson_patch -Headers $AzureDevOpsAuthenicationHeader -ContentType 'application/json' 

    Start-Sleep -Seconds 2 # This is required to wait until desired deployment stage to be patched for deployment


    # Step 6
    # Get Approval Response of the release created
    $requestBody_approval_get= @{
    }
    $requestBody_approval = $requestBody_approval_get | ConvertTo-Json
    $uri_approval_get = "https://vsrm.dev.azure.com/$($OrganizationName)/$($Projectid)/_apis/release/approvals?releaseIdsFilter=$($Releaseid)&api-version=7.0"
    $list_approval_response = Invoke-RestMethod -Uri $uri_approval_get -Method get -body $requestBody_approval -Headers $AzureDevOpsAuthenicationHeader -ContentType 'application/json'

    # Get approval ID that is equal to the desired deployment environment(stage)
    $list_approval_response.value | foreach {if ($_.releaseEnvironment.name -eq $RelaseEnvName) { $appr_id = $_.id}}

    Start-Sleep -Seconds 1

    # Step 7
    # Approve desired stage to be deployed
    $deploymentApprovementbody_json = $deploymentApprovementbody | ConvertTo-Json
    $deploymentApprovementuri = "https://vsrm.dev.azure.com/$($OrganizationName)/$($Projectid)/_apis/release/approvals/$($appr_id)?api-version=7.0"
    $deployment_approval_response = Invoke-RestMethod -Uri $deploymentApprovementuri -Method patch -body $deploymentApprovementbody_json -Headers $AzureDevOpsAuthenicationHeader -ContentType 'application/json'

    # Step 8
    # Get approval IDs of that are not equal to the desired deployment environment(stage) and reject anything else that is not the desired deployment stage
    $envRejectionids = @()
    $list_approval_response.value | foreach {if ($_.releaseEnvironment.name -ne $RelaseEnvName) { $envRejectionids += $_.id}}