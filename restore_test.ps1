
# Test restoring the newest Library Management System backup
# This script creates/replaces ONLY the library_capstone_restore_test database.

$ErrorActionPreference = "Stop"

$BackupDirectory = [System.IO.Path]::GetFullPath(
    (Join-Path $PSScriptRoot "..\backups")
)

$PgBin = "C:\Program Files\PostgreSQL\18\bin"
$PgRestore = Join-Path $PgBin "pg_restore.exe"
$Psql = Join-Path $PgBin "psql.exe"

if (-not (Test-Path $PgRestore)) {
    throw "pg_restore.exe not found: $PgRestore"
}

if (-not (Test-Path $Psql)) {
    throw "psql.exe not found: $Psql"
}

$Backup = Get-ChildItem -Path $BackupDirectory -Filter "library_capstone_*.dump" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $Backup) {
    throw "No library_capstone backup file was found."
}

$TestDatabase = "library_capstone_restore_test"

$SecurePassword = Read-Host "Enter PostgreSQL password" -AsSecureString
$Credential = [System.Net.NetworkCredential]::new("", $SecurePassword)
$env:PGPASSWORD = $Credential.Password

try {
    Write-Host "Checking connection..."
    & $Psql -h localhost -p 5432 -U postgres -d postgres -v ON_ERROR_STOP=1 -c "SELECT 1;" | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Could not connect to PostgreSQL."
    }

    # Recreate only the dedicated restore-test database.
    $Existing = & $Psql -h localhost -p 5432 -U postgres -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$TestDatabase';"

    if ($LASTEXITCODE -ne 0) {
        throw "Could not check whether the test database exists."
    }

    if ($Existing -match "1") {
        & $Psql -h localhost -p 5432 -U postgres -d postgres -v ON_ERROR_STOP=1 -c "DROP DATABASE $TestDatabase WITH (FORCE);"

        if ($LASTEXITCODE -ne 0) {
            throw "Could not remove the previous restore-test database."
        }
    }

    & $Psql -h localhost -p 5432 -U postgres -d postgres -v ON_ERROR_STOP=1 -c "CREATE DATABASE $TestDatabase;"

    if ($LASTEXITCODE -ne 0) {
        throw "Could not create the restore-test database."
    }

    Write-Host "Restoring backup: $($Backup.Name)"

    & $PgRestore -h localhost -p 5432 -U postgres -d $TestDatabase --exit-on-error $Backup.FullName

    if ($LASTEXITCODE -ne 0) {
        throw "Restore failed with exit code $LASTEXITCODE"
    }

    Write-Host "Checking restored tables..."

    & $Psql -h localhost -p 5432 -U postgres -d $TestDatabase -v ON_ERROR_STOP=1 -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"

    if ($LASTEXITCODE -ne 0) {
        throw "Could not inspect restored tables."
    }

    Write-Host "Checking restored book count..."

    & $Psql -h localhost -p 5432 -U postgres -d $TestDatabase -v ON_ERROR_STOP=1 -c "SELECT COUNT(*) AS restored_books FROM books;"

    if ($LASTEXITCODE -ne 0) {
        throw "Could not query books in the restored database."
    }

    Write-Host "Restore test completed. The original database was not modified."
}
finally {
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
    $Credential = $null
    $SecurePassword = $null
}
