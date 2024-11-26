@echo off

SETLOCAL EnableDelayedExpansion

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
    echo Installing Python 3.10.11...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe' -OutFile 'python-3.10.11-amd64.exe'; if ($LASTEXITCODE -ne 0) { exit 1 }}"
    if %errorlevel% NEQ 0 (
        echo Failed to download Python installer.
        exit /b
    )
    start /wait python-3.10.11-amd64.exe /quiet InstallAllUsers=1 PrependPath=1
    del python-3.10.11-amd64.exe
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

REM Install Microsoft.VCRedistif 32bit - 64bit & BuildTools
echo  [INFO] Installing Microsoft.VCRedist.2015+.x64...
winget install -e --id Microsoft.VCRedist.2015+.x64

echo  [INFO] Installing Microsoft.VCRedist.2015+.x86...
winget install -e --id Microsoft.VCRedist.2015+.x86

echo  [INFO] Installing vs_BuildTools...
curl -L -o "%temp%\vs_buildtools.exe" "https://aka.ms/vs/17/release/vs_BuildTools.exe"

if %errorlevel% neq 0 (
  echo  [ERROR] Download failed. Please restart the installer
  pause
) else (
  start "" "%temp%\vs_buildtools.exe" --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
)

REM Cloning the repository
git clone https://github.com/Stability-AI/stable-audio-tools.git
cd stable-audio-tools
REM Setting up the env
python -m venv env
call env\Scripts\activate
REM Installing torch cuda version
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
REM Installing req setup
pip install .
REM Creating ckpt folder + dl model
mkdir ckpt
cd ckpt
curl -L https://huggingface.co/audo/stable-audio-open-1.0/resolve/main/model.safetensors?download=true -o model.safetensors
curl -L https://huggingface.co/audo/stable-audio-open-1.0/resolve/main/model_config.json?download=true -o model_config.json
cd ..
REM Launching the webui
python run_gradio.py --ckpt-path ".\ckpt\model.safetensors" --model-config ".\ckpt\model_config.json" 



