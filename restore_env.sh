#!/bin/bash
echo "Genskaber virtuelt miljø..."
python3 -m venv ~/tempprojekt/venv
source ~/tempprojekt/venv/bin/activate
pip install -r ~/tempprojekt/requirements.txt
echo "Virtuelt miljø genskabt og aktiveret."
