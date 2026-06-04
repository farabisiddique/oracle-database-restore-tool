@echo off
REM ===========================================================================
REM  Installer for Database Restore Tool
REM  - Installs ONLY the compiled jar (Java source is not distributed)
REM  - Target: %LOCALAPPDATA%\DatabaseRestoreTool  (per-user, no admin needed)
REM  - Creates Desktop + Start Menu shortcuts and an "Apps & features" entry
REM ===========================================================================
setlocal
cd /d %~dp0

set "APP_NAME=Database Restore Tool"
set "INSTALL_DIR=%LOCALAPPDATA%\DatabaseRestoreTool"
set "JAR=DbRestoreTool.jar"
set "JARFULL=%INSTALL_DIR%\%JAR%"
set "SM_LNK=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%.lnk"
set "DT_LNK=%USERPROFILE%\Desktop\%APP_NAME%.lnk"
set "RKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\DatabaseRestoreTool"

echo ============================================================
echo   Installing %APP_NAME%
echo   Target: %INSTALL_DIR%
echo ============================================================
echo.

REM 1) Make sure the compiled jar exists (build from source if needed).
if not exist "%JAR%" (
    echo Compiled jar not found - building it...
    call build.bat
)
if not exist "%JAR%" (
    echo.
    echo ERROR: %JAR% is missing and could not be built.
    echo Install a JDK and run build.bat, then run this installer again.
    pause
    exit /b 1
)

REM 2) Find javaw.exe (windowless Java launcher) for the shortcuts.
set "JAVAW="
for /f "delims=" %%j in ('where javaw 2^>nul') do if not defined JAVAW set "JAVAW=%%j"
if not defined JAVAW if defined JAVA_HOME if exist "%JAVA_HOME%\bin\javaw.exe" set "JAVAW=%JAVA_HOME%\bin\javaw.exe"
if not defined JAVAW (
    echo ERROR: javaw.exe not found. Please install a Java JRE or JDK, then retry.
    pause
    exit /b 1
)

REM 3) Copy the compiled app and the uninstaller (no source files are copied).
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
copy /y "%JAR%" "%JARFULL%" >nul
copy /y "uninstall.bat" "%INSTALL_DIR%\uninstall.bat" >nul

REM 4) Manual launcher inside the install folder.
> "%INSTALL_DIR%\Launch.bat" echo @echo off
>> "%INSTALL_DIR%\Launch.bat" echo start "" "%JAVAW%" -jar "%%~dp0%JAR%"

REM 4b) Generate the app icon (.ico) straight from the jar for the shortcuts.
set "ICON=%INSTALL_DIR%\app.ico"
"%JAVAW%" -cp "%JARFULL%" com.farabi.dbrestore.util.IconWriter "%ICON%"
set "ICONLOC=%JAVAW%,0"
if exist "%ICON%" set "ICONLOC=%ICON%,0"

REM 5) Create Start Menu + Desktop shortcuts (no embedded double-quotes in the
REM    PowerShell command; quotes are injected with [char]34 to keep cmd happy).
powershell -NoProfile -ExecutionPolicy Bypass -Command "$w=New-Object -ComObject WScript.Shell; foreach($p in @($env:SM_LNK,$env:DT_LNK)){$s=$w.CreateShortcut($p); $s.TargetPath=$env:JAVAW; $s.Arguments='-jar '+[char]34+$env:JARFULL+[char]34; $s.WorkingDirectory=$env:INSTALL_DIR; $s.IconLocation=$env:ICONLOC; $s.Description=$env:APP_NAME; $s.Save()}"

REM 6) Register in Add/Remove Programs (current user - no admin required).
reg add "%RKEY%" /f /v DisplayName     /t REG_SZ /d "%APP_NAME%" >nul
reg add "%RKEY%" /f /v DisplayVersion  /t REG_SZ /d "1.0.0" >nul
reg add "%RKEY%" /f /v Publisher       /t REG_SZ /d "Earshadul Bari Siddique (Farabi)" >nul
reg add "%RKEY%" /f /v InstallLocation /t REG_SZ /d "%INSTALL_DIR%" >nul
reg add "%RKEY%" /f /v DisplayIcon     /t REG_SZ /d "%ICONLOC%" >nul
reg add "%RKEY%" /f /v UninstallString /t REG_SZ /d "cmd /c \"%INSTALL_DIR%\uninstall.bat\"" >nul
reg add "%RKEY%" /f /v NoModify        /t REG_DWORD /d 1 >nul
reg add "%RKEY%" /f /v NoRepair        /t REG_DWORD /d 1 >nul

echo.
echo Done. %APP_NAME% was installed to:
echo     %INSTALL_DIR%
echo Shortcuts were created on the Desktop and in the Start Menu.
echo To remove it later: Windows "Apps and features", or run uninstall.bat.
echo.
pause
endlocal
