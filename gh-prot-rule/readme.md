## About The Project
The script utilises Github CLI in order to delete or create protection rules for desired branch of a repository in Github.


### Prerequisites
* Bash
* Git
* Github CLI
* Sudo previlage to add the script to the path and make it executable.
* Required repositories must be cloned to the local machine.


### Installation
After installing prerequisites, login your Github CLI: gh auth login

1.Choose Github Server

2.Insert Github hostname

3.Login either with your Github credentials or paste your Github authentication token

4.Clone the repo


## Usage
The script takes 3 arguments, insertion of at least one argument is mandatory. Script usage ./github-branch-prot-rule.sh repository_name branch_name -option.
options:
-h | --help    Print this Help."
-p | --put     Put API request, to create branch protection rules."
-d | --delete  Delete API request, to delete branch protection rules."

API request body is hard-coded to make necessary changes in branch protection rules, and can be edited in the code as required.
