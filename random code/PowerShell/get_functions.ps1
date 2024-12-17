# common utility functions for PowerShell scripts

# renames the branch to new name
function Rename-Branch {
    param (
        [string]$branchName,
        [string]$newName
    )
    try {
        git branch -m $branchName $newName
        return $newName
    } catch {
        Write-Host "Error renaming branch $branchName to $newName"
        return $null
    }
}

function Remove-Branch {
    param (
        [string]$branchName
    )
    try {
        git branch -D $branchName
        Write-Host "Branch $branchName deleted"
        return $true
    } catch {
        Write-Host "Error deleting branch $branchName"
        return $false
    }
}