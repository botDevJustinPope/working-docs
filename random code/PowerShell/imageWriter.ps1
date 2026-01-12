# Run in PowerShell
$cn = "server=wbs-sql.veodesignstudio.com;database=EPLAN_VEO;uid=VDS;pwd=pr0ductiononly!;TrustServerCertificate=true;"
$query = @"
select pattern_id, image_data,
    CASE
        WHEN image_data IS NULL THEN 'NULL'
        -- JPEG (FF D8 FF E0 / E1 / E8)
        WHEN SUBSTRING(image_data, 1, 4) IN (0xFFD8FFE0, 0xFFD8FFE1, 0xFFD8FFE8) THEN '.jpeg'
        -- PNG
        WHEN SUBSTRING(image_data, 1, 8) = 0x89504E470D0A1A0A THEN '.png'
        -- GIF
        WHEN SUBSTRING(image_data, 1, 6) IN (0x474946383761, 0x474946383961) THEN '.gif'
        -- BMP
        WHEN SUBSTRING(image_data, 1, 2) = 0x424D THEN '.bmp'
        -- TIFF (II* or MM*)
        WHEN SUBSTRING(image_data, 1, 4) IN (0x49492A00, 0x4D4D002A) THEN '.tiff'
        -- WebP (RIFF....WEBP)
        WHEN SUBSTRING(image_data, 1, 4) = 0x52494646 AND SUBSTRING(image_data, 9, 4) = 0x57454250 THEN '.webp'
        -- ICO / CUR (icon / cursor)
        WHEN SUBSTRING(image_data, 1, 4) IN (0x00000100, 0x00000200) THEN '.ico'
        -- JPEG 2000 (JP2 signature box)
        WHEN SUBSTRING(image_data, 1, 12) = 0x0000000C6A5020200D0A870A THEN '.jp2'
        -- Photoshop PSD
        WHEN SUBSTRING(image_data, 1, 4) = 0x38425053 THEN '.psd'
        -- PDF
        WHEN SUBSTRING(image_data, 1, 4) = 0x25504446 THEN '.pdf'
        -- ISO BMFF based (HEIF/AVIF/etc) — 'ftyp' at offset 5, brands like 'heic','avif','mif1'
        WHEN SUBSTRING(image_data, 5, 4) = 0x66747970 
             AND SUBSTRING(image_data, 9, 4) IN (0x68656963, 0x61766966, 0x6D696631) THEN '.heif'
        ELSE 'Unknown'
    END AS img_FileType from [EPLAN_VEO].[dbo].[product_patterns]
where pattern_id in (1721)
"@

# ensure target folder exists
$target = "C:\Temp\patternImages"
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

#read binary to find the image file format


while ($r.Read()) {
    $part   = $r["pattern_id"].ToString()
    $bytes  = [byte[]]$r["image_data"]
    $fileType = $r["img_FileType"].ToString()

    if ($fileType -eq "NULL" -or $fileType -eq "Unknown") {
        $fileType = ".jpg" # default extension
    }

    # sanitize filename
    $safe = ("{0}" -f $part) -replace "\s","_" -replace "[^\w\.-]","_"
    $path = Join-Path $target ($safe + $fileType)    # change extension if needed

    [System.IO.File]::WriteAllBytes($path, $bytes)
    Write-Host "Wrote $path"
}

$rows = 0
try {
    while ($r.Read()) {
        $rows++
        $part   = $r["part_no"].ToString()
        $bytes  = [byte[]]$r["image_data"]

        # sanitize filename
        $safe = ("{0}" -f $part) -replace "\s","_" -replace "[^\w\.-]",""
        $path = Join-Path $target ($safe + ".jpg")    # change extension if needed

        try {
            [System.IO.File]::WriteAllBytes($path, $bytes)
            Write-Host "Wrote $path"
        } catch {
            Write-Warning "Failed to write ${$path}: $($Error[0].Exception.Message)"
        }
    }
} catch {
    Write-Error "Error while reading rows: $($_.Exception.Message)"
    Write-Error ( $_.Exception | Format-List * -Force | Out-String )
} finally {
    if ($r) { $r.Close() }
    if ($cnx -and $cnx.State -ne [System.Data.ConnectionState]::Closed) { $cnx.Close() }
    Write-Host "Finished. Rows processed: $rows. Connection state: $($cnx.State)"
}
