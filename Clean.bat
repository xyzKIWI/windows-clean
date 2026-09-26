@echo off
chcp 950 >nul
title Windows 系統垃圾清理與維護工具

echo ======================================================
echo          Windows 系統垃圾清理與維護工具
echo ======================================================
echo.

:: 檢測是否擁有系統管理員權限
net session >nul 2>&1
if %errorlevel% equ 0 goto is_admin
set IS_ADMIN=0
echo [執行身分] 一般使用者 (安全模式)
echo           清理當前使用者空間暫存檔、快取、回收筒與 DNS。
echo           (系統受保護目錄將自動略過，避免權限不足阻擋)
goto start_clean

:is_admin
set IS_ADMIN=1
echo [執行身分] 系統管理員 (完整模式)
echo           將清理全系統與使用者空間垃圾檔案。

:start_clean
echo.

:: 1. 管理員專用：停止 Windows Update 服務並清理更新下載快取
if not "%IS_ADMIN%"=="1" goto skip_winupdate
echo [*] 正在停止更新服務以釋放暫存...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop cryptsvc >nul 2>&1

echo [*] 清理 Windows Update 下載暫存...
del /f /s /q "%windir%\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%p in ("%windir%\SoftwareDistribution\Download\*") do rmdir "%%p" /s /q >nul 2>&1

echo [*] 正在重新啟動更新服務...
net start cryptsvc >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
:skip_winupdate

:: 2. 清理使用者暫存資料夾
echo [*] 正在清理使用者暫存資料夾 (User Temp)...
del /f /s /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*") do rmdir "%%p" /s /q >nul 2>&1

if not "%IS_ADMIN%"=="1" goto skip_sys_temp
echo [*] 正在清理系統暫存 (Windows Temp)...
del /f /s /q "%windir%\Temp\*.*" >nul 2>&1
for /d %%p in ("%windir%\Temp\*") do rmdir "%%p" /s /q >nul 2>&1

echo [*] 正在清理預讀取檔案 (Prefetch)...
del /f /s /q "%windir%\Prefetch\*.*" >nul 2>&1
:skip_sys_temp

:: 3. 清理崩潰傾印與錯誤報告快取
echo [*] 正在清理應用程式崩潰傾印 (User Crash Dumps)...
del /f /s /q "%LOCALAPPDATA%\CrashDumps\*.*" >nul 2>&1
del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\WER\*.*" >nul 2>&1

if not "%IS_ADMIN%"=="1" goto skip_sys_dumps
echo [*] 正在清理系統錯誤傾印與日誌...
del /f /s /q "%windir%\Minidump\*.*" >nul 2>&1
del /f /q "%windir%\Memory.dmp" >nul 2>&1
del /f /s /q "%ProgramData%\Microsoft\Windows\WER\*.*" >nul 2>&1
del /f /s /q "%windir%\*.log" >nul 2>&1
:skip_sys_dumps

:: 4. 清理網路與瀏覽器快取
echo [*] 正在清理 Windows 網路暫存快取 (INetCache)...
del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\INetCache\*.*" >nul 2>&1
for /d %%p in ("%LOCALAPPDATA%\Microsoft\Windows\INetCache\*") do rmdir "%%p" /s /q >nul 2>&1

if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    echo [*] 正在清理 Microsoft Edge 網頁快取...
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1
)

if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    echo [*] 正在清理 Google Chrome 網頁快取...
    del /f /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
)

:: 5. 清理 Windows 圖示與縮圖快取
echo [*] 正在清理檔案總管縮圖與圖示快取...
del /f /s /q /a "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
del /f /s /q /a "%LOCALAPPDATA%\IconCache.db" >nul 2>&1

:: 6. 清理資源回收筒
echo [*] 正在清理資源回收筒...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

if not "%IS_ADMIN%"=="1" goto skip_admin_recycle
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\$Recycle.Bin" (
        rd /s /q "%%d:\$Recycle.Bin" >nul 2>&1
    )
)
:skip_admin_recycle

:: 7. 清除 DNS 解析快取
echo [*] 正在清除 DNS 解析快取...
ipconfig /flushdns >nul 2>&1

echo.
echo ======================================================
echo                  清理作業完成！
if "%IS_ADMIN%"=="0" (
    echo  [說明] 本次已安全清理使用者所有暫存檔與快取。
    echo  若日後以「系統管理員身分執行」，將自動額外清理系統核心層。
)
echo ======================================================
echo.
pause
