[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Command,

    [Parameter(Position = 1)]
    [string] $Path,

    [Alias('h', '?')]
    [switch] $Help
)

$ErrorActionPreference = 'Stop'
$archiveUrl = 'https://github.com/yceachan/modelsim-workflow/archive/refs/heads/main.zip'

function Show-EdaUsage {
    @'
Usage:
  eda new <directory>  Create the ModelSim template in a new or empty directory.
  eda init             Create the template in the empty current directory.
  eda --help           Show this help message.

The generated project contains template files only; no Git repository is created.
'@
}

if ($Help -or [string]::IsNullOrWhiteSpace($Command) -or
    $Command -in @('help', '--help', '-h', '-?')) {
    Show-EdaUsage
    return
}

if ($Command -notin @('new', 'init')) {
    Show-EdaUsage
    throw "Unknown command: $Command"
}

function Test-DirectoryEmpty {
    param([Parameter(Mandatory)][string] $LiteralPath)

    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Container)) {
        return $true
    }

    return $null -eq (Get-ChildItem -LiteralPath $LiteralPath -Force | Select-Object -First 1)
}

switch ($Command) {
    'new' {
        if ([string]::IsNullOrWhiteSpace($Path)) {
            throw 'Usage: eda new <directory>'
        }

        $destination = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    }

    'init' {
        if (-not [string]::IsNullOrWhiteSpace($Path)) {
            throw 'Usage: eda init  (run it inside an empty current directory)'
        }

        $destination = (Get-Location).ProviderPath
    }
}

if ((Test-Path -LiteralPath $destination) -and
    -not (Test-Path -LiteralPath $destination -PathType Container)) {
    throw "Destination is not a directory: $destination"
}

if (-not (Test-DirectoryEmpty -LiteralPath $destination)) {
    throw "Destination must be empty: $destination"
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("modelsim-workflow-" + [guid]::NewGuid().ToString('N'))
$archivePath = Join-Path $tempRoot 'template.zip'
$extractPath = Join-Path $tempRoot 'extract'

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath -UseBasicParsing
    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractPath

    $archiveRoot = Get-ChildItem -LiteralPath $extractPath -Directory | Select-Object -First 1
    if ($null -eq $archiveRoot) {
        throw 'Downloaded template archive is empty.'
    }

    if (-not (Test-Path -LiteralPath $destination)) {
        New-Item -ItemType Directory -Path $destination | Out-Null
    }

    Get-ChildItem -LiteralPath $archiveRoot.FullName -Force |
        Copy-Item -Destination $destination -Recurse -Force

    Write-Host "ModelSim template created at: $destination" -ForegroundColor Green
    Write-Host 'No Git repository was initialized.' -ForegroundColor DarkGray
    Write-Host 'Run .\do.bat to open ModelSim.' -ForegroundColor Cyan
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
