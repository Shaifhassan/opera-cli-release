# install.ps1

$ErrorActionPreference = "Stop"

$repo = "Shaifhassan/opera-cli-release"
$apiUrl = "https://api.github.com/repos/$repo/releases/latest"

$installDir = "$env:LOCALAPPDATA\xkyeron"

$addinUrl = "https://raw.githubusercontent.com/$repo/main/excel/OperaExcelFunctions.xlam"
$addinDir = "$env:APPDATA\Microsoft\AddIns"
$addinDest = Join-Path $addinDir "OperaExcelFunctions.xlam"

Write-Host ""
Write-Host "Opera CLI Installer" -ForegroundColor Cyan
Write-Host "--------------------" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 1. Get latest release information
# ------------------------------------------------------------

Write-Host "Checking latest version..." -ForegroundColor Cyan

$release = Invoke-RestMethod `
    -Uri $apiUrl `
    -Headers @{
        "Accept"     = "application/vnd.github+json"
        "User-Agent" = "opera-cli-installer"
    }

$version = $release.tag_name

$asset = $release.assets |
    Where-Object { $_.name -like "*windows-x86_64.zip" } |
    Select-Object -First 1

if (-not $asset) {
    throw "Could not find a windows-x86_64.zip asset in the latest release ($version)."
}

$url = $asset.browser_download_url

Write-Host "Latest version: $version"

# ------------------------------------------------------------
# 2. Create installation directory
# ------------------------------------------------------------

if (!(Test-Path $installDir)) {
    New-Item `
        -ItemType Directory `
        -Path $installDir `
        -Force | Out-Null
}

# ------------------------------------------------------------
# 3. Download archive
# ------------------------------------------------------------

$tempDir = Join-Path $env:TEMP "opera-cli-install"
$archive = Join-Path $tempDir "opera-cli.zip"

if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}

New-Item `
    -ItemType Directory `
    -Path $tempDir `
    -Force | Out-Null

Write-Host "Downloading Opera CLI $version..." -ForegroundColor Cyan

Invoke-WebRequest `
    -Uri $url `
    -OutFile $archive

# ------------------------------------------------------------
# 4. Extract
# ------------------------------------------------------------

Write-Host "Extracting..." -ForegroundColor Cyan

Expand-Archive `
    -Path $archive `
    -DestinationPath $tempDir `
    -Force

foreach ($exe in "opera_cli.exe", "opera_connector.exe") {

    $source = Join-Path $tempDir $exe

    if (!(Test-Path $source)) {
        throw "Expected file not found in archive: $exe"
    }

    Copy-Item `
        $source `
        (Join-Path $installDir $exe) `
        -Force
}

# ------------------------------------------------------------
# 5. Download and install the Excel add-in
# ------------------------------------------------------------

Write-Host "Downloading Excel add-in..." -ForegroundColor Cyan

if (!(Test-Path $addinDir)) {
    New-Item `
        -ItemType Directory `
        -Path $addinDir `
        -Force | Out-Null
}

Invoke-WebRequest `
    -Uri $addinUrl `
    -OutFile $addinDest

Unblock-File -Path $addinDest

Write-Host "Installed Excel add-in to $addinDest" -ForegroundColor Green

# ------------------------------------------------------------
# 6. Add OperaCLI directory to user PATH
# ------------------------------------------------------------

$userPath = [Environment]::GetEnvironmentVariable(
    "Path",
    "User"
)

$pathEntries = $userPath -split ";"

if ($pathEntries -notcontains $installDir) {

    if ([string]::IsNullOrWhiteSpace($userPath)) {
        $newPath = $installDir
    }
    else {
        $newPath = "$userPath;$installDir"
    }

    [Environment]::SetEnvironmentVariable(
        "Path",
        $newPath,
        "User"
    )

    Write-Host ""
    Write-Host "Added $installDir to your PATH." -ForegroundColor Green
}

# ------------------------------------------------------------
# 7. Cleanup
# ------------------------------------------------------------

Remove-Item `
    $tempDir `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue

# ------------------------------------------------------------
# Complete
# ------------------------------------------------------------

Write-Host ""
Write-Host "Successfully installed Opera CLI $version." -ForegroundColor Green
Write-Host ""
Write-Host "Restart your terminal and run:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    opera_cli --help"
Write-Host ""
Write-Host "To start the connector, run:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    opera_connector.exe"
Write-Host ""
Write-Host "The Excel add-in was downloaded and unblocked. To enable it:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    In Excel, go to File > Options > Add-ins > Manage: Excel Add-ins > Go..."
Write-Host "    Check ""OperaExcelFunctions"" and click OK."
Write-Host ""

# ------------------------------------------------------------
# 8. Optional guided server setup
# ------------------------------------------------------------
# Prefers a local setup-connection.ps1 next to this script (when
# run from a downloaded copy). When run via `irm ... | iex`, there
# is no local file (and no $PSScriptRoot), so it's fetched and run
# from the same repo instead.

$setupScriptUrl = "https://raw.githubusercontent.com/$repo/main/script/setup-connection.ps1"
$localSetupScript = if ($PSScriptRoot) { Join-Path $PSScriptRoot "setup-connection.ps1" } else { $null }

$addConnection = Read-Host "Would you like to add your first server connection now? (Y/n)"

if ($addConnection -notmatch "^(n|no)$") {
    Write-Host ""

    if ($localSetupScript -and (Test-Path $localSetupScript)) {
        & $localSetupScript
    }
    else {
        Invoke-Expression (Invoke-RestMethod -Uri $setupScriptUrl)
    }
}
else {
    Write-Host ""
    Write-Host "You can add a connection later by running:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    irm $setupScriptUrl | iex"
    Write-Host ""
}
