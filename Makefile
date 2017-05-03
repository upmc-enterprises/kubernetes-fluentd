# Makefile for the Docker image upmcenterprises/fluentd
# MAINTAINER: Steve Sloka <slokas@upmc.edu>

.PHONY: all container push

TAG ?= 0.0.2
PREFIX ?= upmcenterprises

all: container

container:
	docker build -t $(PREFIX)/fluentd:$(TAG) .

push:
	docker push $(PREFIX)/fluentd:$(TAG)