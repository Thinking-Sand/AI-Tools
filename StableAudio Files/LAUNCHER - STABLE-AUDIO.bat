@echo off
CALL env\Scripts\activate
python run_gradio.py --ckpt-path ".\ckpt\model.safetensors" --model-config ".\ckpt\model_config.json" 