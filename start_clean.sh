#!/bin/bash
echo "Dræber gamle uvicorn processer..."
pkill uvicorn 2>/dev/null
echo "Starter API på port 8500"
uvicorn main:app --host 0.0.0.0 --port 8500
