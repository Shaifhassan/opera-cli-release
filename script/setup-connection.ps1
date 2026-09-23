# setup-connection.ps1
#
# Guided setup for adding an Oracle server connection to Opera CLI.
# Can be run standalone at any time, or is offered automatically at
# the end of install.ps1.

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Locate opera_cli.exe
# ------------------------------------------------------------
# Resolved directly (not via PATH) so this works even in the same
# terminal session right after install.ps1, before PATH changes
# have taken effect.

function Resolve-OperaCli {

    $cmd = Get-Command "opera_cli.exe" -ErrorAction SilentlyContinue

    if ($cmd) {
        return $cmd.Source
    }

    $fallback = "$env:LOCALAPPDATA\xkyeron\opera_cli.exe"

    if (Test-Path $fallback) {
        return $fallback
    }

    return $null
}

$operaCli = Resolve-OperaCli

if (-not $operaCli) {
    Write-Host ""
    Write-Host "opera_cli.exe was not found." -ForegroundColor Red
    Write-Host "Run install.ps1 first." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "Opera CLI - Guided Server Setup" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# Guided add-oracle loop
# ------------------------------------------------------------

$addAnother = $true

while ($addAnother) {

    $answer = Read-Host "Add an Oracle server connection now? (Y/n)"

    if ($answer -match "^(n|no)$") {
        break
    }

    Write-Host ""

    # Required fields

    do {
        $name = Read-Host "Connection name / resort code (e.g. PROD_DB)"
    } while ([string]::IsNullOrWhiteSpace($name))

    do {
        $hostName = Read-Host "Hostname or IP address"
    } while ([string]::IsNullOrWhiteSpace($hostName))

    do {
        $schema = Read-Host "Opera schema username"
    } while ([string]::IsNullOrWhiteSpace($schema))

    # Optional fields

    $port = Read-Host "Port [default: 1521]"
    $serviceName = Read-Host "Service name [default: OPERA]"
    $description = Read-Host "Description (optional)"

    $cliArgs = @("server", "add-oracle", $name, $hostName, $schema)

    if (-not [string]::IsNullOrWhiteSpace($port)) {
        $cliArgs += @("--port", $port)
    }

    if (-not [string]::IsNullOrWhiteSpace($serviceName)) {
        $cliArgs += @("--service-name", $serviceName)
    }

    if (-not [string]::IsNullOrWhiteSpace($description)) {
        $cliArgs += @("--description", $description)
    }

    Write-Host ""
    Write-Host "Running: opera_cli server add-oracle $name $hostName $schema" -ForegroundColor Cyan
    Write-Host "You will be prompted for the database password next." -ForegroundColor Yellow
    Write-Host ""

    # Runs in the foreground so opera_cli's own secure password
    # prompt is shown directly to the user.
    & $operaCli @cliArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "Failed to add connection '$name'." -ForegroundColor Red
    }
    else {
        Write-Host ""
        Write-Host "Testing connection..." -ForegroundColor Cyan
        & $operaCli server connect $name
    }

    Write-Host ""

    $again = Read-Host "Add another connection? (y/N)"
    $addAnother = $again -match "^(y|yes)$"

    Write-Host ""
}

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host ""
Write-Host "View all configured servers with:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    opera_cli server list"
Write-Host ""
