SHELL := /bin/bash
CWD := $(shell pwd)
APP_NAME = winterfall

DOCKER_HUB_USER=eklhad
WEB_IMAGE_NAME=${APP_NAME}-web
WEB_IMAGE_VERSION=0.1

##########################
# WEB APP HELPERS
#########################
.PHONY: npm_build_frontend
npm_build_frontend:
	cd frontend && \
	npm run-script build

.PHONY: docker_build_web
docker_build_web:
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