# methods to interact with the user

# Get user input for Yes or No, returns true for Yes and false for No
function Get-User-Input-Y-N {
    param {
        [string]$message
    }
    $response = Read-Host $message
    if ($response -eq "Y") {
        return $true
    } elseif ($response -eq "N") {
        return $false
    } else {
        Write-Host "Invalid input. Please enter Y or N"
        Get-User-Input-Y-N -message $message
    }
}