# Run in PowerShell
$cn = "server=wbs-sql.veodesignstudio.com;database=VeoSolutions;uid=VDS;pwd=pr0ductiononly!;TrustServerCertificate=true;"
$query = @"
SELECT
  part_no,
  image_data               -- VARBINARY(MAX)
FROM dbo.veo_colors
 WHERE part_no in ('6CBR12/CS20','6CBR12/CS22','6CBR12/CS23','6CBRP12/CS20','6CBRP12/CS22','6CBRP12/CS23')
"@

# ensure target folder exists
$target = "C:\Temp\Colors"
try {
New-Item -ItemType Directory -Force -Path $target | Out-Null
} catch {
    Write-Error "Could not create target folder $target : $_"
}

try {
    $cnx = New-Object System.Data.SqlClient.SqlConnection $cn
} catch {
    Write-Error "Failed to create SqlConnection object: $_"
    exit 1
}

$cmd = $cnx.CreateCommand()
$cmd.CommandText = $query

try {
    $cnx.Open()
    Write-Host "Connection opened. State: $($cnx.State)"
} catch {
    Write-Error "Failed to open SQL connection: $($_.Exception.Message)"
    # optionally show full details
    Write-Error ( $_.Exception | Format-List * -Force | Out-String )
    exit 1
}

try {
    $r = $cmd.ExecuteReader()
} catch {
    Write-Error "ExecuteReader threw an exception: $($_.Exception.Message)"
    Write-Error ( $_.Exception | Format-List * -Force | Out-String )
    if ($cnx -and $cnx.State -ne [System.Data.ConnectionState]::Closed) { $cnx.Close() }
    exit 1
}

#  for each row, open the image in a browser window
while ($r.Read()) {
    $part   = $r["part_no"].ToString()
    $bytes  = [byte[]]$r["image_data"]

    # sanitize filename
    $safe = ("{0}" -f $part) -replace "\s","_" -replace "[^\w\.-]","_"
    $path = Join-Path $target ($safe + ".png")    # change extension if needed

    [System.IO.File]::WriteAllBytes($path, $bytes)
    Write-Host "Wrote $path"

    # open in default browser
    Start-Process $path
}
$rows = 0
try {
    while ($r.Read()) {
        $rows++
        $part   = $r["part_no"].ToString()
        $bytes  = [byte[]]$r["image_data"]
        # sanitize filename
        $safe = ("{0}" -f $part) -replace "\s","_" -replace "[^\w\.-]","_"
        $path = Join-Path $target ($safe + ".png")    # change extension if needed
        try {
            [System.IO.File]::WriteAllBytes($path, $bytes)
            Write-Host "Wrote $path"
            # open in default browser
            Start-Process $path
        } catch {
            Write-Error "Failed to write file $path : $_"
        }
    }
} catch {
    Write-Error "Error reading data: $_"
} finally {
    if ($cnx -and $cnx.State -ne [System.Data.ConnectionState]::Closed) { $cnx.Close() }
}

