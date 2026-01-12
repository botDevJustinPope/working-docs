$targetImage = "C:\Temp\patternImages\1597.jpg"
$targetPattern = 1597

$cn = "server=wbs-sql.veodesignstudio.com;database=EPLAN_VEO;uid=VDS;pwd=pr0ductiononly!;TrustServerCertificate=true;"
$sqlUpdate = @"
update [EPLAN_VEO].[dbo].[product_patterns]
set image_data = @imageData
where pattern_id = @patternID
"@

#read image file
$imageBytes = [System.IO.File]::ReadAllBytes($targetImage)
#check image bytes
if ($imageBytes.Length -eq 0) {
    Write-Error "Image file $targetImage is empty or could not be read."
    exit 1
}

# execute update
$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = $cn
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = $sqlUpdate

#add parameters 
$paramImage = $cmd.Parameters.Add("@imageData", [System.Data.SqlDbType]::VarBinary, $imageBytes.Length)
$paramImage.Value = $imageBytes
$paramPattern = $cmd.Parameters.Add("@patternID", [System.Data.SqlDbType]::Int)
$paramPattern.Value = $targetPattern

$cmd.ExecuteNonQuery()
$conn.Close()