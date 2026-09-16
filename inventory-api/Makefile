IMAGE_NAME := inventory-api
TAG ?= security

.PHONY: build security 

build:
	docker build -t $(IMAGE_NAME):$(TAG) .
security: build
	./security_gate.sh
	