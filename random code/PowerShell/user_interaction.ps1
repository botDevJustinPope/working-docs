# methods to interact with the user

# Get user input for Yes or No, returns true for Yes and false for No
function Get-User-Input-Y-N {
    param (
        [string]$message
    )
    while ($true) {
        $response = Read-Host $message
        switch ($response.ToUpper()) {
            "Y" { return $true }
            "N" { return $false }
            default { Write-Host "Invalid input. Please enter Y or N" }
        }
    }
}