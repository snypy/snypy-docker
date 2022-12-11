# SnyPy Docker Setup

## Setup Application

* Create `docker-compose.override.yml` based on `docker-compose.override.example.yml` on adapt configuration
* Pull container images: `docker-compose pull`
* Start the database: `docker-compose up -d db`
* Run migrations: `docker-compose run --rm api python manage.py migrate`
* Load data from fixture: `docker-compose run --rm api python manage.py loaddata /fixtures/setup.json`
* Start containers: `docker-compose up`

## Working with fixtures 

Fixtures can be used in order to speed up the setup of the application.

### Creat a new fixture

```bash
docker-compose run --rm api python manage.py dumpdata --indent 4 --output /fixtures/setup.json --natural-foreign --natural-primary auth users shares snippets teams
```

### Load existing fixture

The fixtures are located inside `data/fixtures` which is can be maped in the `docker-compose.override.yml`, ex: `./data/fixtures/:/fixtures/`.

```bash
docker-compose run --rm api python manage.py loaddata /fixtures/setup.json
```

The current fixture available in the repository contains some dumy data, language configuration and an admin (Usernmae: `admin`, Password: `12345678!`)

## Running the REST API locally for development

The following steps are required:

* Create a override file based on the dev confgiuration: `cp docker-compose.override.dev.yml docker-compose.override.yml`
* Clone the code of the rest API: `git clone https://github.com/snypy/snypy-backend.git code/snypy-backend`
* Run docker compose: `docker-compose up`

The api container will load the code form the local volume and start the development server which reload on every change in the python files. All Django command can run via the container: `docker-compose exec api python manage.py makemigrations`

## Make the containers publicly avaialble

In order to make SnyPy publicly avialable I use nginx and Let's Encrypt.

My setup makes use of a subdomain for each service:

* app.snypy.com - Appliction UI
* api.snypy.com - Rest API

Next step is a base webroot configuration fot the [HTTP-01 challenge](https://letsencrypt.org/de/docs/challenge-types/#http-01-challenge) validation;

```nginx
server {
    listen 80;
    server_name app.snypy.com api.snypy.com;

    location ~ /.well-known {
        root /var/www/letsencrypt;
        allow all;
    }
}
```

Afterwards certbot can be used generate the SSL certificates:

```bash
certbot certonly -d app.snypy.com --webroot --webroot-path /var/www/letsencrypt
certbot certonly -d api.snypy.com --webroot --webroot-path /var/www/letsencrypt
```

Once the certificate configuration is done, the subdomains can forward the traffic to the specific container and all traffic can be redirected to https.

```nginx
server {
    listen 80;
    server_name app.snypy.com api.snypy.com;

    location / {
         return 301 https://$host$request_uri;
    }

    location ~ /.well-known {
        root /var/www/letsencrypt;
        allow all;
    }
}

server {
    listen 443;
    server_name app.snypy.com;
    ssl on;
    ssl_certificate     /etc/letsencrypt/live/app.snypy.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.snypy.com/privkey.pem;

    location / {
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8080;
        proxy_redirect off;
    }
}
server {
    listen 443;
    server_name api.snypy.com;
    ssl on;
    ssl_certificate     /etc/letsencrypt/live/api.snypy.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.snypy.com/privkey.pem;

    location / {
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8000;
        proxy_redirect off;
    }
}
```

Also make sure afterwards that the containters are only avaiable via nginx. This can be done by specifing a local IP in the port mapping in the `docker-compose.override.yml`:

```yaml
version: "3"

services:
  api:
    environment:
      ALLOWED_HOSTS: "api.snypy.com"
      DEBUG: "False"
      SECRET_KEY: "SECRET_KEY"
      CORS_ORIGIN_WHITELIST: "https://app.snypy.com"
      REGISTER_VERIFICATION_URL: "https://app.snypy.com/verify-user/"
      RESET_PASSWORD_VERIFICATION_URL: "http://app.snypy.com/set-password/?token={token}"
      REGISTER_EMAIL_VERIFICATION_URL: "https:/app.snypy.com/verify-email/"
      EMAIL_URL: "smtp+tls://user:pass@provider:587"
    ports:
      - "127.0.0.1:8000:8000"

  ui:
    environment:
      REST_API_URL: "https://api.snypy.com/api/v1/"
    ports:
      - "127.0.0.1:8080:80"  

  static:
    profiles:
      - donotstart
```

Afterwards restart the containers and check the status

```bash
user@serverName:/snypy# docker-compose ps
        Name                       Command               State            Ports          
-----------------------------------------------------------------------------------------
snypy-docker_api_1      gunicorn --bind 0.0.0.0:80 ...   Up      127.0.0.1:8000->8000/tcp
snypy-docker_db_1       docker-entrypoint.sh postgres    Up      5432/tcp                
snypy-docker_ui_1       /docker-entrypoint.sh sh e ...   Up      127.0.0.1:8080->80/tcp 
```

## Update env file

* Load environment from file: `export $(cat .env | xargs)`
* Set new environment: `export API_VERSION=1.1.0`
* Update environment file: `envsubst < .env.template > .env`
