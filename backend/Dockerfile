# https://hub.docker.com/alpine/git
FROM alpine/git as src
ARG GIT_HASH="master"
WORKDIR /code
RUN git clone https://github.com/nezhar/snypy-backend --single-branch --branch $GIT_HASH .

# https://hub.docker.com/_/python
FROM python:3.10-slim
COPY --from=src /code/snypy /usr/src/app/snypy
COPY --from=src /code/requirements.txt /usr/src/app/snypy/requirements.txt
WORKDIR /usr/src/app/snypy
RUN pip install --no-cache-dir pip gunicorn psycopg2-binary -U
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000