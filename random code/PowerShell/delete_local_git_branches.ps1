
param (
    [string]$RepoPath
)

. "C:\GitHub\botDevJustinPope\working-docs\random code\PowerShell\user_interaction.ps1"
. "C:\GitHub\botDevJustinPope\working-docs\random code\PowerShell\get_functions.ps1"

function Confirm-Branch-Removal {
    param (
        [string]$branchName
    )
    $message = "Do you want to delete local branch $branchName? (Y[delete]/N)"
    $response = Get-User-Input-Y-N -message $message
    if ($response) {
        Remove-Branch -branchName $branchName
    } 
}

# Validate the file path is a git repo 
Set-Location $RepoPath

# check status, if there are difs, prompt user to commit or stash and try again
try {
    $statusResponse = git status
    if ($statusResponse -match "Your branch is up to date") {
        Write-Host "Working tree is clean. Continuing..."
    } else {
        Write-Host "Working tree is not clean. Please commit or stash changes and try again."
        exit
    }
} catch {
    Write-Host "The file path is not a git repo. Verify the file path and try again."
    exit
}
try {
    # checkout default branch
    git checkout master
} catch {
    Write-Host "This does not have a master branch. Exiting..."
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
    if ($branch -eq "master") {
        Write-Host "Skipping master branch..."
        continue
    }
    Write-Host "Checking branch $branch..."
    $remoteBranch = git branch -r | Where-Object { $_ -match $branch }
    if (-not $remoteBranch) {
        Write-Host "Branch $branch has no remote branch. Starting branch Archive Process..."
        Confirm-Branch-Removal -branchName $branch
    } else {
        # check if the remote branch is deleted
        $remoteCheck = git ls-remote --exit-code origin $branch
        if ($remoteCheck -ne 0) {
            Write-Host "Remote branch $branch is deleted. Starting branch Archive Process..."
            Confirm-Branch-Removal -branchName $branch
        } else {
            Write-Host "Remote branch found. Continuing to next branch..."
        }
    }
}