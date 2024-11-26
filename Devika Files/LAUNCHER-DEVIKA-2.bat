@echo off
CALL env\Scripts\activate
start cmd /k "CALL env\Scripts\activate && cd ui && bun run dev --host"
python devika.py
