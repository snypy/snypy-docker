# https://hub.docker.com/_/python
FROM python:3.10-slim
ARG GIT_HASH="master"
RUN apt-get update && apt-get install git -y
WORKDIR /usr/src/app
RUN git clone https://github.com/nezhar/snypy-backend .
RUN git checkout $GIT_HASH
RUN pip install pip -U
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn psycopg2-binary

WORKDIR /usr/src/app/snypy
EXPOSE 8000
