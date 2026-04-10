param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("major", "minor", "patch")]
    [string]$Bump,

    [ValidateSet("all", "vscode", "cursor")]
    [string]$Target = "all",

    [switch]$SkipVersionBump,
    [switch]$PackageOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Require-Token {
    param([Parameter(Mandatory = $true)][string]$Name)
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Missing environment variable '$Name'. Set it before running release."
    }
    return $value
}

Write-Host "==> argprocolor release started" -ForegroundColor Cyan
Write-Host "    bump: $Bump | target: $Target" -ForegroundColor DarkCyan

Require-Command git
Require-Command npm
Require-Command npx

if (-not $SkipVersionBump) {
    Write-Host "==> Bumping version ($Bump) in package.json" -ForegroundColor Cyan
    npm version $Bump --no-git-tag-version | Out-Host
}

$package = Get-Content -Path ".\package.json" -Raw | ConvertFrom-Json
$version = $package.version
Write-Host "==> Current extension version: $version" -ForegroundColor Green

Write-Host "==> Building VSIX package" -ForegroundColor Cyan
npx @vscode/vsce package | Out-Host

if ($PackageOnly) {
    Write-Host "==> Package-only mode complete. Skipping publish." -ForegroundColor Yellow
    exit 0
}

if ($Target -in @("all", "vscode")) {
    $vscePat = Require-Token "VSCE_PAT"
    Write-Host "==> Publishing to VS Code Marketplace" -ForegroundColor Cyan
    npx @vscode/vsce publish --pat $vscePat | Out-Host
}

if ($Target -in @("all", "cursor")) {
    $ovsxPat = Require-Token "OVSX_PAT"
    Write-Host "==> Publishing to OpenVSX (used by Cursor marketplace)" -ForegroundColor Cyan
    npx ovsx publish -p $ovsxPat | Out-Host
}

Write-Host "==> Release done for version $version" -ForegroundColor Green
Write-Host "Next: git add package.json && git commit -m 'release $version' && git push" -ForegroundColor DarkGreen
