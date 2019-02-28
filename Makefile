SHELL := /bin/bash
CWD := $(shell pwd)
APP_NAME = winterfall

DOCKER_HUB_USER=eklhad
WEB_IMAGE_NAME=${APP_NAME}-web
WEB_IMAGE_VERSION=0.1
WORKER_IMAGE_NAME=${APP_NAME}-worker
WORKER_IMAGE_VERSION=0.1

##########################
# DEV HELPERS
##########################
.PHONY: todo
todo:
	@ag "TODO" --ignore Makefile

##########################
# TERRAFORM HELPERS
##########################
.PHONY: tf_format
tf_format:
	git ls-files '*.tf' | xargs -n 1 terraform fmt

.PHONY: tf_deps
tf_deps: npm_build_frontend docker_build_web docker_build_worker docker_push_web docker_push_worker
	echo "Done building all the images for TF / K8s."

##########################
# WEB APP HELPERS
#########################
.PHONY: npm_build_frontend
npm_build_frontend:
	cd web/frontend && \
	npm run-script build

.PHONY: docker_build_web
docker_build_web:
	cd web/ && \
	docker build . -t ${DOCKER_HUB_USER}/${WEB_IMAGE_NAME}:${WEB_IMAGE_VERSION}

.PHONY: docker_run_web
docker_run_web: 
	docker run -d -p 5000:5000 \
		-e PG_DB_ADDR=${PG_DB_ADDR} \
		-e PG_DB_NAME=${PG_DB_NAME} \
		-e PG_DB_UN=${PG_DB_UN} \
		-e PG_DB_PW=${PG_DB_PW} \
		${DOCKER_HUB_USER}/${WEB_IMAGE_NAME}:${WEB_IMAGE_VERSION}

.PHONY: docker_run_web_dev
docker_run_web_dev: 
	docker run -d -v ${CWD}/web:/web \
		-p 5000:5000 \
		-e PG_DB_ADDR=${PG_DB_ADDR} \
		-e PG_DB_NAME=${PG_DB_NAME} \
		-e PG_DB_UN=${PG_DB_UN}\
		-e PG_DB_PW=${PG_DB_PW} \
		${DOCKER_HUB_USER}/${WEB_IMAGE_NAME}:${WEB_IMAGE_VERSION}
 
.PHONY: docker_push_web
docker_push_web: 
	docker push ${DOCKER_HUB_USER}/${WEB_IMAGE_NAME}:${WEB_IMAGE_VERSION}

##########################
# WORKER HELPERS
#########################
.PHONY: docker_build_worker
docker_build_worker:
	cd worker/ && \
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
