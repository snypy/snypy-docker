# https://hub.docker.com/_/python
FROM python:3.10-slim as build

RUN apt-get update && apt-get install git -y
ARG GIT_HASH="master"
WORKDIR /usr/src/app
RUN git clone https://github.com/nezhar/snypy-backend .
RUN git checkout $GIT_HASH
RUN pip install pip -U
RUN pip install --no-cache-dir -r requirements/base.txt

WORKDIR /usr/src/app/snypy
ENV SECRET_KEY=static
ENV ALLOWED_HOSTS=static
ENV DATABASE_URL=static
ENV CORS_ORIGIN_WHITELIST=static
ENV REGISTER_VERIFICATION_URL=static
ENV RESET_PASSWORD_VERIFICATION_URL=static
ENV REGISTER_EMAIL_VERIFICATION_URL=static
ENV CSRF_TRUSTED_ORIGINS=static
RUN python manage.py collectstatic --noinput


# https://hub.docker.com/_/nginx
FROM nginx:1.21-alpine
COPY --from=build /static /usr/share/nginx/html
