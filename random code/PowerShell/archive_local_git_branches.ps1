# This script is to have a quick way to archive local git branches that are no longer needed
# Input: file path to git repo
# Process:
# 1. Validate if the file path is a git repo
# 2. Get all local branches
# 3. Archive branches that no longer have a remote branch or the remote branch has been deleted
#    Archive Process:
# 3.a check remote branch status
# 3.b if remote branch is deleted, rename local branch to archive/branchName

param (
    [string]$RepoPath
)

. "C:\GitHub\botDevJustinPope\working-docs\random code\PowerShell\user_interaction.ps1"
. "C:\GitHub\botDevJustinPope\working-docs\random code\PowerShell\get_functions.ps1"

function Confirm-User-Branch-Action {
    param {
        [string]$branchName
    }
    $message = "Do you want to archive branch $branchName or delete? (Y[archive]/N[delete])"
    $response = Get-User-Input-Y-N -message $message
    if ($response) {
        Rename-Branch -branchName $branchName -newName "archive/$branchName"
    } else {
        Remove-Branch -branchName $branchName
    }
}

# Validate the file path is a git repo 
Set-Location $RepoPath

if (-not (Test-Path .git)) {
    Write-Host "The file path is not a git repo. Varify the file path and try again."
    exit
}
Write-Host "$RepoPath is a git repo, starting archive process..."
# fetch all remote branches
git fetch --all 

# Get all local branches
$localBranches = git branch | ForEach-Object { $_.TrimStart("*").Trim() }

if (-not $localBranches) {
    Write-Host "No local branches found. Exiting..."
    exit
} else {
    Write-Host "Local branches found: $localBranches"
}

foreach ($branch in $localBranches) {
    Write-Host "Checking branch $branch..."
    $remoteBranch = git branch -r | Where-Object { $_ -match $branch }
    if (-not $remoteBranch) {
        Write-Host "Branch $branch has no remote branch. Starting branch Archive Process..."
        Confirm-User-Branch-Action -branchName $branch
    } else {
        # check if the remote branch is deleted
        $remoteCheck = git ls-remote --exit-code origin $branch
        if ($remoteCheck -ne 0) {
            Write-Host "Remote branch $branch is deleted. Starting branch Archive Process..."
            Confirm-User-Branch-Action -branchName $branch
        } else {
            Write-Host "Remote branch found. Continuing to next branch..."
        }
    }
}
