param (
    [string]
    $Dir = "C:\Program Files\Babashka",
    [string]
    $Version = "latest"
)

$ProgressPreference = 'SilentlyContinue'

function Test-Elevation {
    [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
}

function Ensure-BabashkaProgramFile {
    param (
        [String]
        $Directory
    )
    if (Test-Path -Path $Directory -PathType Container) {
        Get-Item -Path $Directory
    }
    else {
        New-Item -Path $Directory -ItemType Directory
    }
}

function Ensure-BabashkaProgramFileOnPath {
    param (
        $Directory
    )
    $local:OriginalEnvPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path

    if ($OriginalEnvPath.Split(";") -contains $Directory) {
        Write-Output "Babashka is on `$ENV:PATH."
    }
    else {
        $local:DesiredEnvPath = "$OriginalEnvPath;$Directory;"

        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value  $DesiredEnvPath
        $env:path = "$env:path;$Directory"
        Ensure-BabashkaProgramFileOnPath -Directory $Directory
    }
}

function RetrieveBabashka {
    param (
        [string]
        $Version,
        [string]
        $TempFile = $(New-TemporaryFile)
    )
    # Determine Version url
    if ($Version -eq "latest") {
        $local:Releases = Invoke-WebRequest -Uri "https://api.github.com/repos/babashka/babashka/releases/$Version"
    } else {
        $local:Releases = Invoke-WebRequest -Uri "https://api.github.com/repos/babashka/babashka/releases/tags/$Version"
    }
    $local:Assets = ($Releases.Content | ConvertFrom-Json).assets # Get assets
    $local:DownloadUrl = ($Assets | Where-Object { $_.browser_download_url -match 'windows-amd64.zip$' }).browser_download_url # Get Download URL

    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempFile # Download babashka
    Get-Item $TempFile # Return location of babashka
}

function ExpandBabashkaZip {
    param (
        $ZipFile
    )
    $TempDir = $(New-Item -Path $env:TEMP -Name "BBtmp"  -ItemType Directory -Force)
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') > $null #redirect out to silence import
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile.FullName, $TempDir.FullName) > $null
        Get-Item -Path "$env:TEMP\BBtmp\bb.exe"
    }
    else {
        Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force
        Get-Item -Path "$env:TEMP\BBtmp\bb.exe"
    }
}

function InstallBabashka {
    param (
        $TargetDir,
        $ExeLocation
    )
    Move-Item -Path $ExeLocation -Destination $TargetDir -Force
    Write-Output "bb is now installed."
}

if ((Test-Elevation) -and ($Dir -eq "C:\Program Files\Babashka")) {
    Ensure-BabashkaProgramFileOnPath -Directory $(Ensure-BabashkaProgramFile -Directory $Dir).FullName
    $bbZip = RetrieveBabashka -Version $Version
    $bbExe = ExpandBabashkaZip -ZipFile $bbZip
    InstallBabashka -TargetDir $Dir -ExeLocation $bbExe
} else {
    $bbZip = RetrieveBabashka -Version $Version
    $bbExe = ExpandBabashkaZip -ZipFile $bbZip
    InstallBabashka -TargetDir $Dir -ExeLocation $bbExe
}