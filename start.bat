@echo off
title Suifeng Grain - Start
echo ============================================================
echo   Suifeng Grain - Grain Wholesale Management Platform
echo ============================================================
echo.

set "ROOT=%~dp0"
set "MYSQL=D:\1ruan_jian\phpstudy_pro\Extensions\MySQL8.0.12\bin\mysql.exe"
set "MYSQLD=D:\1ruan_jian\phpstudy_pro\Extensions\MySQL8.0.12\bin\mysqld.exe"
set "MYINI=D:\1ruan_jian\phpstudy_pro\Extensions\MySQL8.0.12\my.ini"
set "JAR=%ROOT%backend\target\liulizhifu-backend-1.0.0.jar"

echo [1/4] Check MySQL...
"%MYSQL%" -h127.0.0.1 -uroot -proot -e "SELECT 1" >nul 2>&1
if errorlevel 1 goto TryStartMySQL
echo   MySQL OK
goto DbInit

:TryStartMySQL
echo   MySQL not running, trying to start mysqld...
if exist "%MYSQLD%" start "liulizhifu-mysql" "%MYSQLD%" --defaults-file="%MYINI%"
ping -n 9 127.0.0.1 >nul
"%MYSQL%" -h127.0.0.1 -uroot -proot -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
  echo   Failed to start MySQL. Open phpStudy and start MySQL manually.
  goto END
)
echo   MySQL started

:DbInit

echo [2/4] Init database...
"%MYSQL%" -h127.0.0.1 -uroot -proot --default-character-set=utf8mb4 < "%ROOT%backend\src\main\resources\db\01_schema.sql" >nul 2>&1
if not exist "%ROOT%backend\src\main\resources\db\02_data.sql" (
  echo   02_data.sql not found. Generate it first:
  echo     python backend\src\main\resources\db\gen_data.py
  goto END
)
"%MYSQL%" -h127.0.0.1 -uroot -proot --default-character-set=utf8mb4 liulizhifu < "%ROOT%backend\src\main\resources\db\02_data.sql" >nul 2>&1
echo   Database ready - schema + demo data + accounts

echo [3/4] Start backend on port 8081...
start "liulizhifu-backend" java -jar "%JAR%" --server.port=8081

echo [4/4] Start frontend on port 5180...
cd /d "%ROOT%frontend"
start "liulizhifu-frontend" node node_modules\vite\bin\vite.js --host --port 5180

echo.
echo ============================================================
echo   Local:   http://localhost:5180
echo   LAN:     other PCs in your network can open
echo            http://YOUR_PC_IP:5180   (run: ipconfig)
echo   Login: admin / admin123
echo ============================================================
echo.

:END
pause
