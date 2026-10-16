
# Backup the Library Management System database

$ErrorActionPreference = "Stop"

$BackupDirectory = Join-Path $PSScriptRoot "..\backups"
$BackupDirectory = [System.IO.Path]::GetFullPath($BackupDirectory)

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = Join-Path $BackupDirectory "library_capstone_$Timestamp.dump"

# Locate PostgreSQL's pg_dump utility
$PgDump = "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"

if (-not (Test-Path $PgDump)) {
    throw "pg_dump.exe was not found at: $PgDump"
}

if (-not (Test-Path $BackupDirectory)) {
    New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
}

Write-Host "Backing up library_capstone..."

# Prompt securely for the PostgreSQL password without saving it in this file
$SecurePassword = Read-Host "Enter PostgreSQL password" -AsSecureString
$Credential = [System.Net.NetworkCredential]::new("", $SecurePassword)
$env:PGPASSWORD = $Credential.Password

try {
    & $PgDump `
        --host localhost `
        --port 5432 `
        --username postgres `
        --dbname library_capstone `
        --format custom `
        --file $BackupFile

    if ($LASTEXITCODE -ne 0) {
        throw "pg_dump failed with exit code $LASTEXITCODE"
    }

    Write-Host "Backup completed successfully:"
    Write-Host $BackupFile
}
finally {
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
    $Credential = $null
    $SecurePassword = $null
}
