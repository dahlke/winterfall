SHELL := /bin/bash
CWD := $(shell pwd)
APP_NAME = winterfall

DOCKER_HUB_USER=eklhad
WORKER_IMAGE_NAME=${APP_NAME}-worker
WORKER_IMAGE_VERSION=0.1

##########################
# WORKER HELPERS
#########################
.PHONY: docker_build_worker
docker_build_worker:
	docker build . -t ${DOCKER_HUB_USER}/${WORKER_IMAGE_NAME}:${WORKER_IMAGE_VERSION}

.PHONY: docker_run_worker
docker_run_worker: 
	docker run -d \
		-e PG_DB_ADDR=${PG_DB_ADDR} \
		-e PG_DB_NAME=${PG_DB_NAME} \
		-e PG_DB_UN=${PG_DB_UN} \
		-e PG_DB_PW=${PG_DB_PW} \
		${DOCKER_HUB_USER}/${WORKER_IMAGE_NAME}:${WORKER_IMAGE_VERSION}

.PHONY: docker_run_worker_dev
docker_run_worker_dev: 
	docker run -d -v ${CWD}/worker:/worker \
		-e PG_DB_ADDR=${PG_DB_ADDR} \
		-e PG_DB_NAME=${PG_DB_NAME} \
		-e PG_DB_UN=${PG_DB_UN}\
		-e PG_DB_PW=${PG_DB_PW} \
		${DOCKER_HUB_USER}/${WORKER_IMAGE_NAME}:${WORKER_IMAGE_VERSION}

.PHONY: docker_push_worker
docker_push_worker: 
	docker push ${DOCKER_HUB_USER}/${WORKER_IMAGE_NAME}:${WORKER_IMAGE_VERSION}
