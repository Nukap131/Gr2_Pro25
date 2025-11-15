FROM python:3.11-slim

WORKDIR /app

# Kopiér requirements
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Kopiér FastAPI-kode
COPY main.py /app/main.py

# Kopiér database mountes som volume senere
# COPY sensordata.db /app/sensordata.db

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
