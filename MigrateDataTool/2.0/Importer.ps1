param(
    [Parameter(Mandatory = $false)]
    [String] $ConfigFile    
)
$ErrorActionPreference = "Stop"


if ($ConfigFile -eq '') {
    if ([IO.File]::Exists("$PSScriptRoot\Config.json")) {
        $ConfigFile = [IO.Path]::GetFullPath("$PSScriptRoot\Config.json")
    }
    else {
        Write-Host 'No config file found! Make sure that you include the file config.json in the same folder of this script or write path as parameter' -ForegroundColor Red
        Write-Error 'No Config file error'
    }
}

$Config = ConvertFrom-Json ([IO.File]::ReadAllText($ConfigFile, [Text.Encoding]::UTF8))

$URL = [String] $Config.ServiceURL
$force = [Boolean] $Config.Force
$ImportId = [String] $Config.ImportID
$overwrite = [Boolean] $Config.Overwrite;

if (($Config.UseSystemDlls -eq $true) -or ($Config.UseSystemDlls -eq $null)) {
    Add-Type -assembly 'System.IO.Compression'
    Add-Type -assembly 'System.IO.Compression.FileSystem'
}
else {
    Add-Type -Path ".\Lib\System.IO.Compression.dll"
    Add-Type -Path ".\Lib\System.IO.Compression.FileSystem.dll"
}


$Proxy = New-WebServiceProxy -Uri $URL -UseDefaultCredential

$timeout = $Config.Timeout

if ($timeout -gt 0) {    
    $Proxy.Timeout = $timeout
}
else {
    $Proxy.Timeout = 600000
}


foreach ($JsonFolder in $Config.JSONFolder) {
    Write-Host "Processing JSON Folder $JsonFolder" -ForegroundColor Yellow
    

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
        }
        else {
            $TableId = [Int32] $Table
        }

        if ($Config.ProcessTable) {
            if ($TableId -ne [Int32] $Config.ProcessTable) { continue }
        }

        Write-Host "Processing table id $TableId" -ForegroundColor Green

        $TableFolder = "$JsonFolder\$TableId"
        if (-not [IO.Directory]::Exists($TableFolder)) { continue }

        foreach ($File in Get-ChildItem $TableFolder -Filter *.json -File ) {
    
            $ZipFile = "$($File.Fullname).zip"
            try {
                Write-Host "  Processing file $($File.Name)"

                
                [System.IO.Compression.ZipArchive] $arch = [System.IO.Compression.ZipFile]::Open($ZipFile, [System.IO.Compression.ZipArchiveMode]::Update)
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($arch, $File.FullName, $File.Name) | Out-Null
                $arch.Dispose() | Out-Null
			 
            
                $ZipBytes = [IO.File]::ReadAllBytes($ZipFile)            
                $ZipBytesB64 = [Convert]::ToBase64String($ZipBytes)
            
                $size = [System.Text.Encoding]::ASCII.GetByteCount($ZipBytesB64) / 1MB
                Write-Host "    Uploading JSON file: size " $size " MB"
                if ($size -ge 1) {
                    $chunkArray = [System.Collections.ArrayList]@()
                    $strLen = 900000
                    $ArrayLen = $ZipBytesB64.Length
                    for ($j = 0; $j -lt $ArrayLen; $j += $strLen) {
                    
                        if (($j + $strLen) -ge $ArrayLen) {
                            $chunkArray.Add($ZipBytesB64.Substring($j, $ArrayLen - $j)) | Out-Null
                        }
                        else {
                            $chunkArray.Add($ZipBytesB64.Substring($j, $strLen)) | Out-Null
                        }
                    }

                    #Write-Host "stop split"
                    $maxChunk = $chunkArray.Count
                    for ($i = 0; $i -lt $maxChunk; $i++) {
                        $perc = [math]::Round(($i / $maxChunk * 100))
                        Write-Progress -Activity "Importing chunks" -Status "$perc% Complete:" -PercentComplete $perc;
                        $Proxy.ImportChunk($ImportId, $chunkArray[$i], $i + 1, $maxChunk) | Out-Null
                    }
                    Write-Progress -Activity "Importing chunks" -Status "Ready" -Completed               

                    $r = $Proxy.ImportFileFromChunkForce($ImportId, $force)
                    
                
                }
                else {
                    $r = $Proxy.ImportZipFileForce($ImportId, $ZipBytesB64, $force)
                }			
								
                $r = ConvertFrom-Json $r
                Write-Host "    Running import"
                #Read-Host "Ready?"	
                if ($overwrite -eq $false) {
                    $Proxy.SetNoOverwrite($ImportId, $r.TableId, $r.EntryNo)
                }
                $ImportResult = $Proxy.ExecuteImport($ImportId, $r.TableId, $r.EntryNo)
                $ImportResult = (ConvertFrom-Json $ImportResult)[0]
                if ("$($ImportResult.Message)" -eq "") {
                    write-host "    OK" -ForegroundColor Green
                }
                else {
                    Write-Host "    $($ImportResult.Message)" -ForegroundColor Red
                }

            }
            finally {
                if ([IO.File]::Exists($ZipFile)) {
                    [IO.File]::Delete($ZipFile)
                }
                [System.GC]::Collect()
            }
        }
    }
}

