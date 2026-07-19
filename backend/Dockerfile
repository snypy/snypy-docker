# https://hub.docker.com/_/debian/
FROM --platform=$BUILDPLATFORM debian as src
RUN apt-get update && apt-get install -y git
ARG GIT_HASH="master"
WORKDIR /code
RUN git clone https://github.com/snypy/snypy-backend --single-branch --branch $GIT_HASH .

# https://hub.docker.com/_/python
FROM python:3.12-slim
COPY --from=src /code/snypy /usr/src/app/snypy
COPY --from=src /code/pyproject.toml /usr/src/app/pyproject.toml

WORKDIR /usr/src/app/
RUN pip install --no-cache-dir pip gunicorn -U

ARG TARGETPLATFORM
# run the command if it does not match arm/v7
RUN if [ "$TARGETPLATFORM" != "linux/arm/v7" ]; then \
        pip install --no-cache-dir psycopg2-binary; \
    fi
# run the command if it matches arm/v7
RUN if [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
        apt-get update && apt-get install -y libpq-dev gcc && \
        pip install --no-cache-dir psycopg2; \
        apt-get remove -y gcc && apt-get autoremove -y; \
    fi

RUN pip install --no-cache-dir -e .

COPY entrypoint.sh /entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["sh", "/entrypoint.sh"]
