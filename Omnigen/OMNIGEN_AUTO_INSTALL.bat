@echo off
SETLOCAL EnableDelayedExpansion

:: Set error handling
set "ERROR_COUNT=0"
set "INSTALLATION_COMPLETE=false"

:: Create a log file
set "LOG_FILE=%TEMP%\omnigen_install_%DATE:~-4,4%%DATE:~-10,2%%DATE:~-7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.log"
set "LOG_FILE=%LOG_FILE: =0%"

:: Function to log messages
call :log "Installation started"

:: Check if running as admin
net session >nul 2>&1
if %errorlevel% EQU 0 (
    echo [ERROR] Please run this script without administrator privileges.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Check Python version
echo Checking Python installation...
python --version >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Installing Python 3.10.11...
    call :log "Installing Python 3.10.11"
    
    powershell -Command "& {Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe' -OutFile 'python-3.10.11-amd64.exe'}" || (
        echo [ERROR] Failed to download Python installer.
        call :log "Failed to download Python installer"
        set /a ERROR_COUNT+=1
        goto :error_handler
    )
    
    start /wait python-3.10.11-amd64.exe /quiet InstallAllUsers=0 PrependPath=1
    del python-3.10.11-amd64.exe
) else (
    for /f "tokens=2" %%I in ('python --version 2^>^&1') do set PYTHON_VERSION=%%I
    if not "!PYTHON_VERSION:~0,4!"=="3.10" (
        echo [NOTE] Current Python version: !PYTHON_VERSION!
        echo [NOTE] This script works best with Python 3.10.11. If you experience issues, please install Python 3.10.11.
        call :log "Non-recommended Python version detected: !PYTHON_VERSION!"
    )
)

:: Check Git installation
echo Checking Git installation...
git --version >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Installing Git...
    call :log "Installing Git"
    
    powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.3/Git-2.41.0.3-64-bit.exe' -OutFile 'Git-2.41.0.3-64-bit.exe'}" || (
        echo [ERROR] Failed to download Git installer.
        call :log "Failed to download Git installer"
        set /a ERROR_COUNT+=1
        goto :error_handler
    )
    
    start /wait Git-2.41.0.3-64-bit.exe /VERYSILENT
    del Git-2.41.0.3-64-bit.exe
)

:: Clone repository
echo Cloning OmniGen repository...
if exist "OmniGen" (
    rmdir /s /q "OmniGen"
)

git clone https://github.com/VectorSpaceLab/OmniGen || (
    echo [ERROR] Failed to clone repository.
    call :log "Failed to clone repository"
    set /a ERROR_COUNT+=1
    goto :error_handler
)

:: Download launcher
echo Downloading launcher...
powershell -Command "& {Invoke-WebRequest -Uri 'https://huggingface.co/Aitrepreneur/FLX/resolve/main/LAUNCHER.bat?download=true' -OutFile 'OmniGen\LAUNCHER.bat'}" || (
    echo [ERROR] Failed to download launcher.
    call :log "Failed to download launcher"
    set /a ERROR_COUNT+=1
    goto :error_handler
)

:: Setup virtual environment
echo Setting up Python virtual environment...
cd OmniGen || (
    echo [ERROR] Failed to enter OmniGen directory.
    call :log "Failed to enter OmniGen directory"
    set /a ERROR_COUNT+=1
    goto :error_handler
)

python -m venv env || (
    echo [ERROR] Failed to create virtual environment.
    call :log "Failed to create virtual environment"
    set /a ERROR_COUNT+=1
    goto :error_handler
)

call env\Scripts\activate || (
    echo [ERROR] Failed to activate virtual environment.
    call :log "Failed to activate virtual environment"
    set /a ERROR_COUNT+=1
    goto :error_handler
)

:: Install requirements
echo Installing Python packages...
call :log "Installing Python packages"

pip install -e . || (
    echo [ERROR] Failed to install package in editable mode.
    call :log "Failed to install package in editable mode"
    set /a ERROR_COUNT+=1
)

pip install torch==2.3.1+cu118 torchvision --extra-index-url https://download.pytorch.org/whl/cu118 || (
    echo [ERROR] Failed to install PyTorch.
    call :log "Failed to install PyTorch"
    set /a ERROR_COUNT+=1
)

pip install gradio spaces || (
    echo [ERROR] Failed to install Gradio.
    call :log "Failed to install Gradio"
    set /a ERROR_COUNT+=1
)

pip install -r requirements.txt || (
    echo [ERROR] Failed to install requirements.
    call :log "Failed to install requirements"
    set /a ERROR_COUNT+=1
)

if !ERROR_COUNT! GTR 0 goto :error_handler

set "INSTALLATION_COMPLETE=true"
echo Starting OmniGen...
python app.py
goto :eof

:error_handler
echo.
echo Installation encountered !ERROR_COUNT! error(s).
echo Check the log file for details: !LOG_FILE!
echo.
if not "!INSTALLATION_COMPLETE!"=="true" (
    echo Common solutions:
    echo - Ensure you have a stable internet connection
    echo - Run the script without administrator privileges
    echo - Make sure that you have the python 3.10.11 installed AND added to path
    echo - Send me a dm on Patreon with your log file
    echo.
    echo Press any key to exit...
    pause >nul
)
exit /b 1

:log
echo %DATE% %TIME% - %~1 >> "!LOG_FILE!"
goto :eof