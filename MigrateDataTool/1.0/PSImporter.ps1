param(

    # Service where stuff should go
    # This service might need to have NTLM enabled.
    [Parameter(Mandatory = $true)]
    [String] $ServiceUrl,

    # Folder where JSON files are stored
    [Parameter(Mandatory = $true)]
    [String] $JsonFolder,

    # The ID of the App to be imported
    [Parameter(Mandatory = $true)]
    [Guid] $ImportId,

    # The ID of the table to import. Leave 0 to import the entire package.
    [Parameter(Mandatory = $false)]
    [Int32] $ReqTableId = 0
)

$ErrorActionPreference = "Stop"

$Proxy = New-WebServiceProxy -Uri $ServiceUrl -UseDefaultCredential
# Goes in timeout? increment this
$Proxy.Timeout = 600000

$IndexFile = [IO.Path]::Combine($JsonFolder, "index.json")
if ([IO.File]::Exists($IndexFile)) {
    $TableList = ConvertFrom-Json ([IO.File]::ReadAllText($IndexFile, [Text.Encoding]::UTF8))
}
else {
    $TableList = Get-ChildItem $JsonFolder -Directory | Sort-Object
}

foreach ($Table in $TableList) {
    
    if ($Table.Name) {
        if ($Table.Name.StartsWith(".")) { continue }
        $TableId = [Int32] $Table.Name
    } else {
        $TableId = [Int32] $Table
    }

    if ($ReqTableId) {
        if ($TableId -ne $ReqTableId) { continue }
    }

    Write-Host "Processing table id $TableId" -ForegroundColor Green

    $TableFolder = "$JsonFolder\$TableId"
    if (-not [IO.Directory]::Exists($TableFolder)) { continue }

    foreach ($File in Get-ChildItem $TableFolder -Filter *.json -File ) {
    
        $ZipFile = "$($File.Fullname).zip"
        try {
            Write-Host "  Processing file $($File.Name)"
            Compress-Archive -Path $File.FullName -DestinationPath $ZipFile
            
            $ZipBytes = [IO.File]::ReadAllBytes($ZipFile)            
            $ZipBytesB64 = [Convert]::ToBase64String($ZipBytes)
            
            $size = [System.Text.Encoding]::ASCII.GetByteCount($ZipBytesB64) / 1MB
            Write-Host "    Uploading JSON file: size " $size " MB"
            if ($size -ge 1) {
                $chunkArray = [System.Collections.ArrayList]@()
                $strLen = 900000
                $ArrayLen = $ZipBytesB64.Length
                for ($j=0; $j -lt $ArrayLen; $j += $strLen){
                    
                    if (($j+$strLen) -ge $ArrayLen) {
                        $chunkArray.Add($ZipBytesB64.Substring($j, $ArrayLen -$j)) | Out-Null
                    }
                    else{
                        $chunkArray.Add($ZipBytesB64.Substring($j,$strLen)) | Out-Null
                    }
                }

                #Write-Host "stop split"
                $maxChunk = $chunkArray.Count
                for ($i=0; $i -lt $maxChunk; $i++) {
                    $perc = [math]::Round(($i/$maxChunk*100))
                    Write-Progress -Activity "Importing chunks" -Status "$perc% Complete:" -PercentComplete $perc;
                    $Proxy.ImportChunk($ImportId, $chunkArray[$i], $i+1, $maxChunk) | Out-Null
                }
                $r = $Proxy.ImportFileFromChunk($ImportId)
                
            }
            else {
                $r = $Proxy.ImportZipFile($ImportId, $ZipBytesB64)
            }
            $r = ConvertFrom-Json $r
            Write-Host "    Running import"
            #Read-Host "Ready?"
            $ImportResult = $Proxy.ExecuteImport($ImportId, $r.TableId, $r.EntryNo)
            $ImportResult = (ConvertFrom-Json $ImportResult)[0]
            if ("$($ImportResult.Message)" -eq "") {
                write-host "    OK" -ForegroundColor Green
            } else {
                Write-Host "    $($ImportResult.Message)" -ForegroundColor Red
            }

        }
        finally {
            if ([IO.File]::Exists($ZipFile)) {
                [IO.File]::Delete($ZipFile)
            }
        }
    }
}