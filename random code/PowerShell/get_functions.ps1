# common utility functions for PowerShell scripts

# renames the branch to new name
function Rename-Branch {
    param {
        [string]$branchName,
        [string]$newName
    }
    git branch -m $branchName $newName
    return $newName
}

function Remove-Branch {
    param {
        [string]$branchName
    }
    git branch -D $branchName
    return $true
}