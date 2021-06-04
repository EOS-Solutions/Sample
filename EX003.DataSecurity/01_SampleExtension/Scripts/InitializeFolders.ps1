function Initialize-Folders {
    
    param(
        # The project folder to initialize
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$ProjectFolder
    )

    Write-Host "Creating folder structure..."
    New-Item -ItemType Directory -Path "$ProjectFolder\Source" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\Codeunit" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\Enum" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\EnumExt" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\Page" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\PageExt" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\Query" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\Report" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\Table" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Source\TableExt" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Documentation\AppSource" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Documentation\AppSource\en" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Documentation\AppSource\it" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Documentation\AppSource\de" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Other" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\PermissionSet" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Test" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Translations" -Force | Out-Null
    New-Item -ItemType Directory -Path "$ProjectFolder\Upgrade" -Force | Out-Null

    Write-Host "Folder structure created..." -ForegroundColor green 

}