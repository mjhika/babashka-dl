param (
    [string]
    $Dir
)

$ProgressPreference = 'SilentlyContinue'

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
    
    if ($Directory) {
        Expand-Archive -Path $tmpf -DestinationPath $Directory
        Write-Host "Babashka is installed in $Directory"
    } else {
        Expand-Archive -Path $tmpf -DestinationPath (Ensure-InstallDir) -Force
        Write-Host "Babashka is installed in C:\Program Files\Babashka"
        Ensure-InstallDirOnPath
    }
}

DownloadLatestBabashka $Dir
