#!/bin/bash

# Clone the repository
echo "[INFO] Cloning the repository..."
git clone https://github.com/Stability-AI/stable-audio-tools
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to clone repository."
    exit 1
fi

# Navigate into the repository folder
cd stable-audio-tools || exit

# Install the required Python packages
echo "[INFO] Installing requirements..."
pip install .

# Create the ckpt directory
echo "[INFO] Setting up ckp directory..."
mkdir ckpt
cd ckpt || exit

# Update system and install libsndfile
echo "[INFO] Installing libsndfile..."
apt-get update
apt-get install -y libsndfile1

# Download the model file
echo "[INFO] Downloading the model file..."
curl -L -o "model.safetensors" "https://huggingface.co/audo/stable-audio-open-1.0/resolve/main/model.safetensors?download=true"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to download model.safetensors."
    exit 1
fi

# Download the model configuration file
echo "[INFO] Downloading the model configuration file..."
curl -L -o "model_config.json" "https://huggingface.co/audo/stable-audio-open-1.0/resolve/main/model_config.json?download=true"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to download model_config.json."
    exit 1
fi

# Navigate back to the main folder
cd ..

# Launch the application
echo "[INFO] Launching the application..."
python run_gradio.py --ckpt-path "./ckpt/model.safetensors" --model-config "./ckpt/model_config.json" --share
