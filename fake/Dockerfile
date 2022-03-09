FROM python:3.8-slim-buster
RUN apt-get update
WORKDIR /app
RUN pip install Flask twilio
COPY . .
ENTRYPOINT [ "python", "app.py"]
