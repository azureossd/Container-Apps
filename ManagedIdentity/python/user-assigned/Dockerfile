FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt /app/

RUN pip install -r requirements.txt

COPY . /app/

CMD ["gunicorn", "-b", "0.0.0.0", "app:app", "--timeout 600"]

EXPOSE 8000