## About The Project
This project is built in order automate Azure deployments in release pipelines with one command to shorten manual UI work on Azure DevOps. The project consist of one bash script `pre-deploy.sh` to determine deployable micro-services for the git branch and Azure release environment that is input by user and one powershell script `deployment.ps1` to deploy code to desired release pipeline by utilising Azure API.

### Prerequisites
* Bash
* PowerShell
* Git
* Azure CLI
* PSWriteColor - Install-Module -Name PSWriteColor
* Sudo previlage to add the script to the path and make it executable.
* All repositories must be cloned on the local machine.


### Installation
After installing prerequisites, login Azure CLI: az login

1.Get an Azure API Token

2.Clone the repo

3.Enter your API in deployment.ps1
$AzureDevOpsPAT = 'ENTER YOUR API TOKEN'
or
Open the current user’s profile into a text editor
```sh
vi ~/.bashrc or vi ~/.zshrc
```
Add the export command.
```sh
export $AzureDevOpsPAT='ENTER YOUR API TOKEN'
```
Save your changes.
To apply all changes to bash_profile, use the source command.
```sh
source ~/.bashrc or source ~/.zhsrc
```