@echo off
REM LANACC — restore a backup .sql into the local PostgreSQL database
REM Usage:  scripts\restore.bat db\backups\lanacc_backup_YYYYMMDD_HHMMSS.sql
if "%~1"=="" (
  echo Usage: %~nx0 ^<path-to-backup.sql^>
  exit /b 1
)
type "%~1" | docker exec -i lanacc-db psql -U lanacc -d lanacc
echo Restore from %~1 complete.
