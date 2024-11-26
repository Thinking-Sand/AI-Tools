#!/bin/bash

# Clone the OmniGen repository
git clone https://github.com/VectorSpaceLab/OmniGen

# Navigate into the repository folder
cd OmniGen

# Install the project in editable mode
pip install -e .

# Install specific versions of torch and torchvision
pip install torch==2.3.1+cu118 torchvision --extra-index-url https://download.pytorch.org/whl/cu118

# Install Gradio and Spaces
pip install gradio spaces

# Install other Python requirements
pip install -r requirements.txt

# Run the application with the --share argument
python app.py --share
