@echo off
REM LANACC — backup the local PostgreSQL database to db\backups\
setlocal
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do set DT=%%I
set STAMP=%DT:~0,8%_%DT:~8,6%
set FILE=lanacc_backup_%STAMP%.sql

docker exec lanacc-db pg_dump -U lanacc -d lanacc --clean --if-exists > db\backups\%FILE%
echo Backup written to db\backups\%FILE%
endlocal
