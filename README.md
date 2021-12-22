# SnyPy Docker Setup

## Setup Application

* Create `docker-compose.override.yml` based on `docker-compose.override.example.yml` on adapt configuration
* Start containers: `docker-compose up`
* Run migrations: `docker-compose run --rm api python manage.py migrate`
* Load data from fixture: `docker-compose run --rm api python manage.py loaddata /fixtures/setup.json`

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
