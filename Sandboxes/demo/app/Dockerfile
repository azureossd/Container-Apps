FROM python:3.14-slim

RUN apt-get update \
	&& apt-get install --yes --no-install-recommends curl ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY server.py request.py ./

ENV ANIMAL_PORT=8080
EXPOSE 8080

CMD ["python", "/app/server.py"]