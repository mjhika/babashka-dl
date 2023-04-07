param (
    [string]
    $Dir
)

$ProgressPreference = 'SilentlyContinue'

function Test-Elevation {
    [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")    
}

function Ensure-InstallDir {
    $local:InstallDir = 'C:\Program Files\Babashka'
    if (Test-Path -Path $InstallDir -PathType Container) {
        Get-Item -Path $InstallDir
    } else {
        New-Item -Path $InstallDir -ItemType Directory
    }
}

function Ensure-InstallDirOnPath {
    $local:OriginalEnvPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
    $local:bbDir = 'C:\Program Files\Babashka\'

    if ($OriginalEnvPath.Split(";") -contains $bbDir) {
        Write-Output "Babashka is on `$ENV:PATH."
    } else {
        $local:DesiredEnvPath = "$OriginalEnvPath;$bbDir"

        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value  $DesiredEnvPath
        $env:path="$env:path;C:\Program Files\Babashka"
        Ensure-InstallDirOnPath
    }
}

function DownloadLatestBabashka {
    param (
        [string]
        $Directory
    )
    $local:Releases = Invoke-WebRequest -Uri 'https://api.github.com/repos/babashka/babashka/releases/latest'
    $local:Assets = ($Releases.Content | ConvertFrom-Json).assets
    $local:LatestDownloadUrl = ($Assets | Where-Object {$_.browser_download_url -match 'windows-amd64.zip$'}).browser_download_url
    $local:tmpf = New-TemporaryFile
    
    Invoke-WebRequest -Uri $latestDownloadUrl -OutFile $tmpf
    
    # I'll have to go fix this later. Reads horribly in my opinion, but will inflate the archive regardless of PSVer
    # The first if checks if you supplied a directory.
    # The second if checks PS version
    if ($Directory) {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            if (Test-Path -Path (Join-Path $Directory "bb.exe") -PathType Leaf) {Remove-Item (Join-Path $Directory "bb.exe")}
            [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') > $null #redirect out to silence import
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tmpf, (Resolve-Path $Directory).Path)
        } else {
            Expand-Archive -Path $tmpf -DestinationPath $Directory -Force
        }
        Write-Host "Babashka is installed in $Directory"
    } elseif (Test-Elevation) {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') > $null #redirect out to silence import
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tmpf, (Ensure-InstallDir).FullName)
        } else {
            Expand-Archive -Path $tmpf -DestinationPath (Ensure-InstallDir) -Force
        }
        Write-Host "Babashka is installed in C:\Program Files\Babashka"
        Ensure-InstallDirOnPath
    } else {
        Write-Error "To install to `$env:path you need to run as admin."
    }
}

DownloadLatestBabashka $Dir
