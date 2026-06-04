@echo off
REM ===========================================================================
REM  Uninstaller for Database Restore Tool
REM  Removes shortcuts, the Add/Remove Programs entry, and the install folder
REM  (%LOCALAPPDATA%\DatabaseRestoreTool). Folder deletion is deferred because
REM  this script may be running from inside that folder.
REM ===========================================================================
setlocal
set "APP_NAME=Database Restore Tool"
set "INSTALL_DIR=%LOCALAPPDATA%\DatabaseRestoreTool"
set "SM_LNK=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%.lnk"
set "DT_LNK=%USERPROFILE%\Desktop\%APP_NAME%.lnk"
set "RKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\DatabaseRestoreTool"

echo Uninstalling %APP_NAME%...
choice /c YN /n /m "Remove %APP_NAME% and all of its files? [Y/N] "
if errorlevel 2 goto cancel

del "%SM_LNK%" >nul 2>&1
del "%DT_LNK%" >nul 2>&1
reg delete "%RKEY%" /f >nul 2>&1

REM Defer folder removal to a detached helper so a running copy here is released.
cd /d "%TEMP%"
> "%TEMP%\drt_cleanup.bat" echo @echo off
>> "%TEMP%\drt_cleanup.bat" echo timeout /t 1 /nobreak ^>nul
>> "%TEMP%\drt_cleanup.bat" echo rmdir /s /q "%INSTALL_DIR%"
>> "%TEMP%\drt_cleanup.bat" echo del "%%~f0"
start "" /min "%TEMP%\drt_cleanup.bat"

echo.
echo %APP_NAME% has been uninstalled.
echo (Your generated output\ and logs\ under the install folder are removed too.)
timeout /t 2 /nobreak >nul
goto end

:cancel
echo Uninstall cancelled.
pause

:end
endlocal
