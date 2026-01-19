FROM python:3.9-slim

RUN pip install --upgrade pip setuptools jaraco.context

WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
