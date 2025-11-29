FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY subscriber.py /app/

CMD ["python3", "-u", "subscriber.py"]

RUN pip install paho-mqtt
