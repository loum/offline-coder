.SILENT:
.DEFAULT_GOAL := help

# Use a single bash shell for each job, and immediately exit on failure
SHELL := zsh
.SHELLFLAGS := -ceu
.ONESHELL:

#
# Makester overrides.
#
MAKESTER__STANDALONE := true
MAKESTER__INCLUDES := py docs docker microk8s
MAKESTER__PROJECT_NAME := offline-coder
MAKESTER__REPO_NAME := loum

include $(HOME)/.makester/makefiles/makester.mk
include makefiles/container-images.mk
include makefiles/terraform-providers.mk

CODER_RELEASE := v2.18.2
MAKESTER__BUILD_COMMAND := --rm --no-cache\
 --build-arg CODER_RELEASE=$(CODER_RELEASE)\
 --build-arg ARCH=$(_ARCH)\
 --build-arg UNAME=$(_UNAME)\
 --build-arg DOCKER_PROVIDER_VERSION=$(DOCKER_PROVIDER_VERSION)\
 --build-arg KUBERNETES_PROVIDER_VERSION=$(KUBERNETES_PROVIDER_VERSION)\
 --build-arg CODER_ENVBUILDER_PROVIDER_VERSION=$(CODER_ENVBUILDER_PROVIDER_VERSION)\
 --tag $(MAKESTER__IMAGE_TAG_ALIAS)\
 --file docker/Dockerfile .

#
# Local Makefile targets.
#
install i:
	helm install coder coder-v2/coder -n coder\
 --values coder-2.18.2/helm/coder/values.yaml\
 --set coder.image.repo=loum/offline-coder\
 --set coder.image.tag=b90ecd0\
 $(DEBUG)

install-debug id: DEBUG := --dry-run --debug
install-debug id: install

uninstall u:
	helm uninstall coder -n coder

get-all ga:
	kubectl get all -n coder

get-events ge:
	kubectl get events --sort-by=".metadata.managedFields[0].time" -n coder

help: makester-help
	printf "\n(Makefile)\n"
	$(call help-line,get-all,Get all resources in the \"coder\" k8s namespace)
	$(call help-line,get-events,Get events in the \"coder\" k8s namespace)
	$(call help-line,install,Install offline-coder \"$(MAKESTER__IMAGE_TAG_ALIAS)\")
	$(call help-line,install-debug,Install (debug mode) offline-coder \"$(MAKESTER__IMAGE_TAG_ALIAS)\")
	$(call help-line,uninstall,Uninstall offline-coder)
	$(MAKE) container-images-help
	$(MAKE) terraform-providers-help
