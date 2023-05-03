SHELL=/bin/bash
DOCKER_COMPOSE=docker compose
DOCKER_ENVIRONMENT=docker-compose.yml
PACKAGE_NAME=app
VENV_FOLDER=venv
LAUNCH_IN_VENV=source ${VENV_FOLDER}/bin/activate &&
PYTHON_VERSION=python3.11

# target: all - Default target. Does nothing.
all:
	@echo "Hello $(LOGNAME), nothing to do by default"
	@echo "Try 'make help'"

# target: help - Display callable targets.
help:
	@egrep "^# target:" [Mm]akefile

# target: setup - prepare environment
setup:
	rm -rf ${VENV_FOLDER}
	${PYTHON_VERSION} -m venv ${VENV_FOLDER}
	${LAUNCH_IN_VENV} pip install -r requirements-dev.txt

# target: build - Build the docker images
build:
	${DOCKER_COMPOSE} -f ${DOCKER_ENVIRONMENT} build

# target: run - Run the project
run:
	${DOCKER_COMPOSE} -f ${DOCKER_ENVIRONMENT} up -d

# taget: down - Stop the project
down:
	${DOCKER_COMPOSE} -f ${DOCKER_ENVIRONMENT} down -v

# target: clean-volumes - Stop the project and clean all volumes
clean-volumes:
	${DOCKER_COMPOSE} -f ${DOCKER_ENVIRONMENT} down -v

# target: logs - Show project logs
logs:
	${DOCKER_COMPOSE} -f ${DOCKER_ENVIRONMENT} logs -f

# target: enter postgres shell
.PHONY: postgres
postgres:
	${DOCKER_COMPOSE} exec web-db psql -U postgres

.PHONY: build-schema
build-schema:
	${DOCKER_COMPOSE} exec web python app/db.py

# target: test - test code
.PHONY: test-web
test-web:
	${DOCKER_COMPOSE} exec web python -m pytest

# target: lint - Lint the code
.PHONY: lint
lint:
	${PRE_RUN_API_COMMAND} lint

# target: apply_black_isort - Run black and isort
apply_black_isort:
	${LAUNCH_IN_VENV} black ${PACKAGE_NAME} tests
	${LAUNCH_IN_VENV} isort ${PACKAGE_NAME} tests

# target: Initalize using aerich
.PHONY: aerich-init-db
aerich-init-db:
	${DOCKER_COMPOSE} exec web aerich init-db
