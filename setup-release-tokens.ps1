param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-SecretAsPlainText {
    param([Parameter(Mandatory = $true)][string]$Prompt)

    $secure = Read-Host -Prompt $Prompt -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Set-UserEnv {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )
    [Environment]::SetEnvironmentVariable($Name, $Value, "User")
}

function Get-UserEnv {
    param([Parameter(Mandatory = $true)][string]$Name)
    return [Environment]::GetEnvironmentVariable($Name, "User")
}

$existingVsce = Get-UserEnv -Name "VSCE_PAT"
$existingOvsx = Get-UserEnv -Name "OVSX_PAT"

if (-not $Force -and -not [string]::IsNullOrWhiteSpace($existingVsce) -and -not [string]::IsNullOrWhiteSpace($existingOvsx)) {
    Write-Host "VSCE_PAT and OVSX_PAT already exist at User scope." -ForegroundColor Yellow
    Write-Host "Run with -Force to overwrite." -ForegroundColor Yellow
    exit 0
}

$vscePat = Read-SecretAsPlainText -Prompt "Enter VS Code Marketplace PAT (VSCE_PAT)"
if ([string]::IsNullOrWhiteSpace($vscePat)) {
    throw "VSCE_PAT cannot be empty."
}

$ovsxPat = Read-SecretAsPlainText -Prompt "Enter OpenVSX PAT (OVSX_PAT)"
if ([string]::IsNullOrWhiteSpace($ovsxPat)) {
    throw "OVSX_PAT cannot be empty."
}

Set-UserEnv -Name "VSCE_PAT" -Value $vscePat
Set-UserEnv -Name "OVSX_PAT" -Value $ovsxPat

Write-Host "Saved VSCE_PAT and OVSX_PAT to User environment." -ForegroundColor Green
Write-Host "Restart terminal/Cursor before running release scripts." -ForegroundColor Cyan
