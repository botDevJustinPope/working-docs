param (
    [string] $filePath,
    [string] $content
)

# Check if the file exists
if (Test-Path $filePath) {
    # If the file exists, append the content
    Add-Content -Path $filePath -Value $content
} else {
    # If the file does not exist, create it and write the content
    Set-Content -Path $filePath -Value $content
}