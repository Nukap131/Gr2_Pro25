FROM python:3.10-slim

WORKDIR /app

COPY main.py /app/
COPY mqtt_handler.py /app/
COPY requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt

CMD ["uvicorn", "--app-dir", "/app", "main:app", "--host", "0.0.0.0", "--port", "8000"]
