function Initialize-Project {
    
    param(
        # The project folder to initialize
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $ProjectFolder
    )

    $GitVersion = ""
    try {
        $GitVersion = & git --version
    }
    catch {
        # ignore
    }
    if ($GitVersion -eq "") {
        Write-Warning "Git does not appear to be installed. Skipping Remote repository related tasks."
    }

    $AppManifest = ConvertFrom-Json -InputObject ([IO.File]::ReadAllText("$ProjectFolder\app.json"))
    if ("$($AppManifest.id)" -ne "") {
        throw "This project has already been initialized. Aborting."
    }

    Write-Host "Initializing project" -ForegroundColor Cyan
    $ProjectGuid = [Guid]::NewGuid()

    $DefaultProjectName = Resolve-Path "$PSScriptRoot\.."
    $DefaultProjectName = [IO.Path]::GetFileName($DefaultProjectName)

    Write-Host " "
    Write-Host -ForegroundColor Cyan "Project-Type"
    Write-Host "PUBLIC : Standard app published in AppSource"
    Write-Host "SHARED: Private EOS App designed and shared between different customer"
    Write-Host "CUSTOM: Designed and builded for one single customer"
    Do {
        Write-Host " "
        $ProjectType = Read-Host -Prompt "Project type (PUBLIC, SHARED, CUSTOM)"
        $ProjectType = $ProjectType.ToUpper()
    } While ($ProjectType -notin ('PUBLIC', 'SHARED', 'CUSTOM')) 

    # verify if used repo name is valid...
    $AppName = $DefaultProjectName
    $AppName = $AppName.Replace(".IT", " forItaly")
    $ExtCode = ""
    if ($ProjectType -in ('PUBLIC', 'SHARED')) {
      $Ok = $true
      if (-not ($DefaultProjectName.ToUpper().SubString(0, 4) -eq 'EOS.' )) {
        $Ok = $false
      } elseif ($ProjectType -in ('PUBLIC')) {
        $AppName = $AppName.SubString(4)
      }
      if ($DefaultProjectName.ToUpper().IndexOf('.EX') -lt 0 ) {
        $Ok = $false
      } elseif ($ProjectType -in ('PUBLIC')) {
        $Pos = $AppName.ToUpper().IndexOf('EX')
        if ( $AppName.IndexOf('.', $Pos) -gt $Pos ) {
            $ExtCode = $AppName.Substring($Pos, ($AppName.IndexOf('.', $Pos) - $Pos))
            $AppName = $AppName.Substring($AppName.IndexOf('.', $Pos) + 1)
        }
      }
      if (-not($Ok)) {
        Write-Host "Attention! Repo name ($DefaultProjectName) used for $ProjectType apps is not like EOS conventions!"
        Write-Host "It has to be of this form Eos.GranuleID.AppName (Without Spaces, Camel Case) "
        Write-Host "Example : Eos.EX001.NewFunction "
        $YesNo = Read-Host -Prompt "Continue anyway (Y/N)?"
        if ( -not ($YesNo.ToUpper() -eq "Y")) {
            exit 
        }
      }

      if ($ProjectType -in ('PUBLIC')) {
        $AppName = $AppName.Replace(".", "")
      }
    }

    if ($ProjectType -in ('CUSTOM')) {
        $Ok = $true
        if ($DefaultProjectName.ToUpper().SubString(0, 4) -eq 'EOS.' ) {
          $Ok = $false
        }
        if ($DefaultProjectName.ToUpper().IndexOf('.EXT') -lt 0 ) {
          $Ok = $false
        }
        if (-not($Ok)) {
            Write-Host "Attention! Repo name ($DefaultProjectName) used for $ProjectType apps is not like EOS conventions!"
            Write-Host "It has to be of this form <CustomerName>.Ext.AppName (Without Spaces, Camel Case) !"
            Write-Host "Example : Askoll.Ext.NewFunction "
            $YesNo = Read-Host -Prompt "Continue anyway (Y/N)?"
            if ( -not ($YesNo.ToUpper() -eq "Y")) {
                exit 
            }
        }
    }
    $AppName = $AppName.Replace(",", "")
    $AppName = $AppName.Replace("-", "")
    $AppName = $AppName.Replace("/", "")
    $AppName = $AppName.Replace(":", "")
    $AppName = $AppName.Replace("+", "")
    $AppName = $AppName.Replace("_", "")


    Write-Host " "
    Write-Host -ForegroundColor Cyan "App configuration"
    $HelpStr = $AppName.toCharArray()
    $AppName = ""
    foreach ($Elem in $HelpStr) {
      if (($Elem.ToString() -ceq $Elem.ToString().ToUpper()) -and ($Elem.ToString() -ne ' ')) {  
          $AppName = $AppName + ' '
      }
      $AppName = $AppName + $Elem
    }
    $AppName = $AppName.Trim()

    $ProjectName = Read-Host -Prompt "Project/App name (Default: $AppName)"
    if ("$ProjectName" -eq "") {
        $ProjectName = $AppName
    }

    $ExtensionCode = Read-Host -Prompt "Extension code [eg. EX000] (Default: $ExtCode)"
    if ("$ExtensionCode" -eq "") {
        $ExtensionCode = $ExtCode
    }

    $ProjectPublisher = Read-Host -Prompt "Publisher (Default: EOS Solutions)"
    if ("$ProjectPublisher" -eq "") {
        $ProjectPublisher = "EOS Solutions"
    }

    [int]$HlpId = 18004100
    if ($ProjectType -eq 'CUSTOM') {
        $HlpId = 50000
    } elseif ($ProjectType -eq 'SHARED') {
        $HlpId = 80000
    } else {
        $HlpId = 18004100
    }
    [int]$ProjectFromId = Read-Host -Prompt "From ID offset (Default: $HlpId)"
    if (!$ProjectFromId) {
        $ProjectFromId = $HlpId
    }

    [int]$HlpId = 18129999
    if ($ProjectType -eq 'CUSTOM') {
        $HlpId = 79999
    } elseif ($ProjectType -eq 'SHARED') {
        $HlpId = 89999
    } else {
        $HlpId = 18129999
    }
    [int]$ProjectToId = Read-Host -Prompt "To ID offset (Default: $HlpId)"
    if (!$ProjectToId) {
       $ProjectToId = $HlpId
    }

    Write-Host " "
    Write-Host -ForegroundColor Cyan "GIT configuration"
    $ProjectRemoteUrl = ""
    if ($GitVersion -ne "") {
        Write-Host "Project repository URL"
        Write-Host "  0. No Repo "
        Write-Host "  1. Labs     : https://eossolutionsspa.visualstudio.com/Eos.Nav.Platform/_git/$DefaultProjectName "
        Write-Host "  2. NON-Labs : https://hg.eos-solutions.it/scm/git/$DefaultProjectName "
        Do {
            Write-Host " "
            [int]$Answer = Read-Host -Prompt "Insert URL (Default 0)"
            if (!$Answer) {
                $Answer = 0
             }
        } While ($Answer -notin (0, 1, 2)) 
        if ($Answer -eq 1) {
            $ProjectRemoteUrl = "https://eossolutionsspa.visualstudio.com/Eos.Nav.Platform/_git/$DefaultProjectName"
        }
        if ($Answer -eq 2) {
            $ProjectRemoteUrl = "https://hg.eos-solutions.it/scm/git/$DefaultProjectName"
        }
        #$ProjectRemoteUrl = Read-Host -Prompt "Insert URL (0)"
        if ("$ProjectRemoteUrl" -ne "") {
            & git remote rename origin template
            & git remote add origin $ProjectRemoteUrl
            & git checkout -b master
        }
    }

    Write-Host " "
    Write-Host -ForegroundColor Cyan "Localization Level / Supported languages"
    Write-Host " 0 : only for italian market                    it-IT"
    Write-Host " 1 : STANDARD deploy                            it-(IT, CH)  &  en-US"
    Write-Host " 2 : lev. 1 + GERMAN local.                     de-(DE, AT, CH)"
    Write-Host " 3 : lev. 2 + FRENCH local.                     fr-(FR, CH, CA, BE)"
    Write-Host " 4 : lev. 3 + DUTCH, DANISH, SHPANISH localiz.  nl-(NL, BE), da-DK, es-ES"
    Write-Host " 9 : ALL possible localizations"
    Do {
        Write-Host " "
        [int]$LocaleLevel = Read-Host -Prompt "Level (Default: 1)"
        if (!$LocaleLevel) {
            $LocaleLevel = 1
         }
    } While ($LocaleLevel -notin (0, 1, 2, 3, 4, 9)) 
  
    $AppManifest.id = $ProjectGuid
    $AppManifest.name = $ProjectName
    $AppManifest.publisher = $ProjectPublisher
    $AppManifest.idRange.from = $ProjectFromId
    $AppManifest.idRange.to = $ProjectToId

    $AppManifest.supportedlocales = @("it-IT")
    if ($LocaleLevel -ge 1) {
        $AppManifest.supportedlocales += @("it-CH")
        $AppManifest.supportedlocales += @("en-US") 
        #, "en-CA", "en-AU", "en-NZ", "en-GB")
    } 
    if ($LocaleLevel -ge 2) {
        $AppManifest.supportedlocales += @("de-DE", "de-AT", "de-CH")
    } 
    if ($LocaleLevel -ge 3) {
        $AppManifest.supportedlocales += @("fr-FR", "fr-BE", "fr-CH", "fr-CA")
    } 
    if ($LocaleLevel -ge 4) {
        $AppManifest.supportedlocales += @("nl-NL", "nl-BE")
        $AppManifest.supportedlocales += @("da-DK")
        $AppManifest.supportedlocales += @("es-ES")
    } 

    # define project specific URL for Help --> replace/insert <app-name> in Help-Url
    $AppName = $AppManifest.Name
    $AppName = $AppName.Replace(" ", "-")
    $AppName = $AppName.ToLower()
    $AppManifest.help = $AppManifest.help.Replace("app-name", $AppName)
    Write-Host "Help-Url: $($AppManifest.help)"

    [IO.File]::WriteAllText("$ProjectFolder\app.json", (ConvertTo-Json -InputObject $AppManifest))



    $AppManifestTest = ConvertFrom-Json -InputObject ([IO.File]::ReadAllText("$ProjectFolder\app.json"))
    $AppManifestTest.id = [Guid]::NewGuid()
    $AppManifestTest.name = "$($AppManifest.name) Test"
    $AppManifestTest.features = @()
    $AppManifestTest.PsObject.Members.Remove('supportedlocales')

    $AppManifestTest.dependencies += @{
        "appId" = $AppManifest.id
        "name" = $AppManifest.name
        "publisher" = $AppManifest.publisher
        "version" = $AppManifest.version
    }

    [IO.File]::WriteAllText("$ProjectFolder\app.test.json", (ConvertTo-Json -InputObject $AppManifestTest))

    $CustMetaData = ConvertFrom-Json -InputObject ([IO.File]::ReadAllText("$ProjectFolder\CustomMetadata.json"))
    $CustMetaData.ProjectType = $ProjectType
    $CustMetaData.ExtensionCode = $ExtensionCode
    $CustMetaData.LocaleLevel = $LocaleLevel.ToString()
    $CustMetaData.LocaleW1 = "0"
    $CustMetaData.LocaleIT = "0"
    if ($AppManifest.supportedLocales -match '-IT' ) {
        $CustMetaData.LocaleIT = "1"
    }
    $CustMetaData.LocaleDE = "0"
    if ($AppManifest.supportedLocales -match '-DE' ) {
        $CustMetaData.LocaleDE = "1"
    }
    $CustMetaData.LocaleUS = "0"
    if ($AppManifest.supportedLocales -match '-US' ) {
        $CustMetaData.LocaleUS = "1"
    }
    $CustMetaData.LocaleFR = "0"
    if ($AppManifest.supportedLocales -match '-FR' ) {
        $CustMetaData.LocaleFR = "1"
    }
    $CustMetaData.LocaleNL = "0"
    if ($AppManifest.supportedLocales -match '-NL' ) {
        $CustMetaData.LocaleNL = "1"
    }
    $CustMetaData.LocaleES = "0"
    if ($AppManifest.supportedLocales -match '-ES' ) {
        $CustMetaData.LocaleES = "1"
    }
    $CustMetaData.LocaleDK = "0"
    if ($AppManifest.supportedLocales -match '-DK' ) {
        $CustMetaData.LocaleDK = "1"
    }
    [IO.File]::WriteAllText("$ProjectFolder\CustomMetadata.json", (ConvertTo-Json -InputObject $CustMetaData))

    Write-Host " "
    Write-Host -ForegroundColor Cyan "Folder structure"
    . $PSScriptRoot\InitializeFolders.ps1
    Initialize-Folders -ProjectFolder $ProjectFolder    
    
    Write-Host " "
    Write-Host "Project initialized successfully" -ForegroundColor Green

    Write-Host " "
    Write-Host "AppID : $($AppManifest.id)" -ForegroundColor yellow
    Write-Host " "
}