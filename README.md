# SnyPy Docker Setup

## Setup Application

* Create `docker-compose.override.yml` based on `docker-compose.override.example.yml` on adapt configuration
* Start containers: `docker-compose up`
* Run migrations: `docker-compose run --rm app python manage.py migrate`
* Load data from fixture: `docker-compose run --rm app python manage.py loaddata /fixtures/setup.json`

## Working with fixtures 

Fixtures can be used in order to speed up the setup of the application.

### Creat a new fixtures

```bash
docker-compose run --rm app python manage.py dumpdata --indent 4 --output /fixtures/setup.json --natural-foreign --natural-primary auth users shares snippets teams
```
