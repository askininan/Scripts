#!/usr/bin/env bash

############################################################
# Request body                                             #
############################################################
request_body='{
        "required_status_checks": {
          "strict": false,
          "contexts": []
        },
        "enforce_admins": true,
        "required_pull_request_reviews": {
          "dismissal_restrictions": {
            "users": ["users"],
            "teams": ["teams/*"]
          },
          "dismiss_stale_reviews": false,
          "require_code_owner_reviews": false,
          "required_approving_review_count": 1,
          "require_last_push_approval":false
        },
        "restrictions": {
          "users": ["users"],
          "teams": ["teams/*"],
          "apps": ["apps"]
        },
        "allow_force_pushes": true
      }'

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Syntax: scriptTemplate [-h|-p|-d]"
   echo "options:"
   echo "h     Print this Help."
   echo "p     Put API request, to create branch protection rules."
   echo "d     Delete API request, to delete branch protection rules."
}

############################################################
# Put request                                              #
############################################################
gh_put() 
{
  # Applies the branch protection specified in request_body function to chosen branch
  gh api --method PUT repos/:owner/:repo/branches/$2/protection --input /tmp/config-branch-rules >/dev/null
  gh api repos/:owner/:repo/branches/$2/protection 
}

############################################################
# Delete request                                           #
############################################################
gh_delete()
{
  gh api -X DELETE repos/:owner/:repo/branches/$2/protection
  gh api repos/:owner/:repo/branches/$2/protection 
}

############################################################
# Parse args                                               #
############################################################
args()
{
while [[ $# -eq 3 ]];
    do
      # Get the options
      case $3 in
        -h | --help )  # display Help
            Help "$@"
            exit;;
        -p | --put )  # put request
            cd ~/repo/$1
            echo $request_body >/tmp/config-branch-rules
            gh_put "$@"
            exit;;
        -d | --delete )  # delete request
            cd ~/repo/$1
            gh_delete "$@"
            exit;;
        * ) # Invalid option
            echo "Error: Invalid option"
            exit;;
      esac
    done
}

############################################################
# main function                                            #
############################################################
main()
{
  if [ $# -ne 3 ]
  then
    echo "Script usage ./github-branch-prot-rule.sh repository_name branch_name -option" 
  else
    args "$@"
  fi
}

# Execute main
main "$@"




