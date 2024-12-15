.SILENT:
.DEFAULT_GOAL := help

# Use a single bash shell for each job, and immediately exit on failure
SHELL := zsh
#.SHELLFLAGS := -ceu
#.ONESHELL:

#
# Makester overrides.
#
MAKESTER__STANDALONE := true
MAKESTER__INCLUDES := py docs docker microk8s
MAKESTER__PROJECT_NAME := offline-coder
MAKESTER__REPO_NAME := loum

include $(HOME)/.makester/makefiles/makester.mk
include makefiles/container-images.mk

CODER_RELEASE := v2.18.0
CODER_PROVIDER_VERSION := 2.0.2
DOCKER_PROVIDER_VERSION := 3.0.2
KUBERNETES_PROVIDER_VERSION := 2.35.0
MAKESTER__BUILD_COMMAND := --rm --no-cache\
 --build-arg CODER_RELEASE=$(CODER_RELEASE)\
 --build-arg DOCKER_PROVIDER_VERSION=$(DOCKER_PROVIDER_VERSION)\
 --build-arg KUBERNETES_PROVIDER_VERSION=$(KUBERNETES_PROVIDER_VERSION)\
 --tag $(MAKESTER__IMAGE_TAG_ALIAS)\
 --file docker/Dockerfile .

help: makester-help
	@echo "(Makefile)\n"
	$(MAKE) container-images-help
