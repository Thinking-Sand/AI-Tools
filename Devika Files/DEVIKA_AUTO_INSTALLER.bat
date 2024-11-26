@echo off
SETLOCAL EnableDelayedExpansion

start cmd /k powershell -c "irm bun.sh/install.ps1|iex"

REM Environment Variables winget
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Winget is not installed on this system.
    echo [INFO] Installing Winget...
    curl -L -o "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "https://github.com/microsoft/winget-cli/releases/download/v1.6.2771/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    echo [INFO] Winget installed successfully.
) else (
    echo [INFO] Winget is already installed.
)

REM Check and install Python
python --version > NUL 2>&1
if %errorlevel% NEQ 0 (
    echo Installing Python 3.10.6...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe' -OutFile 'python-3.10.6-amd64.exe'; if ($LASTEXITCODE -ne 0) { exit 1 }}"
    if %errorlevel% NEQ 0 (
        echo Failed to download Python installer.
        exit /b
    )
    start /wait python-3.10.6-amd64.exe /quiet InstallAllUsers=1 PrependPath=1
    del python-3.10.6-amd64.exe
) else (
    echo Python already installed.
)

REM Check and install Git
git --version > NUL 2>&1
if %errorlevel% NEQ 0 (
    echo Installing Git...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.3/Git-2.41.0.3-64-bit.exe' -OutFile 'Git-2.41.0.3-64-bit.exe'; if ($LASTEXITCODE -ne 0) { exit 1 }}"
    if %errorlevel% NEQ 0 (
        echo Failed to download Git installer.
        exit /b
    )
    start /wait Git-2.41.0.3-64-bit.exe /VERYSILENT
    del Git-2.41.0.3-64-bit.exe
) else (
    echo Git already installed.
)

REM Check if Node.js is installed if not then install Node.js
call node --version > nul 2>&1
if %errorlevel% neq 0 (
    echo  [WARN] Node.js is not installed on this system.
    echo  [INFO] Installing Node.js using Winget...
    winget install --id OpenJS.NodeJS.LTS -e --silent --accept-source-agreements --accept-package-agreements
    echo  [INFO] Node.js installed successfully. Please restart the Installer.
    pause
    exit
) else (
    echo [INFO] Node.js is already installed.
)

REM Cloning the repository
git clone https://github.com/stitionai/devika.git

REM Setting up a Python virtual environment
cd devika
python -m venv env
CALL env\Scripts\activate

REM Installing PyTorch for NVIDIA GPU
pip install torch torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu118

REM Installing other Python requirements
pip install -r requirements.txt

REM Installing playwright & npm
playwright install --with-deps

cd ui/

REM Check if package.json already exists
if not exist package.json (
    echo package.json not found. Downloading...
    curl -L -o package.json "https://huggingface.co/Aitrepreneur/package/resolve/main/package.json?download=true"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to download package.json. Please check the URL and internet connection.
        pause
        exit /b %errorlevel%
    )
) else (
    echo package.json already exists. Skipping download.
)

start cmd /k npm install

bun install

bun add vite

echo the installation was succesfull, do not forget to put the LAUNCHER-DEVIKA.bat file inside the folder and run that
pause