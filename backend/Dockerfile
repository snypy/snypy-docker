# https://hub.docker.com/alpine/git
FROM alpine/git as src
ARG GIT_HASH="master"
WORKDIR /code
RUN git clone https://github.com/snypy/snypy-backend --single-branch --branch $GIT_HASH .

# https://hub.docker.com/_/python
FROM python:3.12-slim
COPY --from=src /code/snypy /usr/src/app/snypy
COPY --from=src /code/requirements /usr/src/app/requirements

WORKDIR /usr/src/app/
RUN pip install --no-cache-dir pip gunicorn psycopg2-binary -U
RUN pip install --no-cache-dir -r requirements/base.txt

COPY entrypoint.sh /entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["sh", "/entrypoint.sh"]
