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
MAKESTER__INCLUDES := py docs docker microk8s argocd
MAKESTER__PROJECT_NAME := offline-coder
MAKESTER__REPO_NAME := loum

include $(HOME)/.makester/makefiles/makester.mk
include makefiles/container-images.mk
include makefiles/terraform-providers.mk

CODER_RELEASE := 2.18.5
MAKESTER__VERSION := $(CODER_RELEASE)-$(shell echo $(MAKESTER__UNAME) | tr '[:upper:]' '[:lower:]')
MAKESTER__RELEASE_NUMBER ?= 1

MAKESTER__IMAGE_TARGET_TAG := $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)

MAKESTER__BUILD_COMMAND := --rm --no-cache\
 --build-arg CODER_RELEASE=v$(CODER_RELEASE)\
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
	helm install coder coder-v2/coder\
 --namespace coder --create-namespace\
 --values coder-$(CODER_RELEASE)/helm/coder/values.yaml\
 --set coder.image.repo=loum/offline-coder\
 --set coder.image.tag=$(MAKESTER__IMAGE_TARGET_TAG)\
 $(DEBUG)

debug-install-debug di: DEBUG := --dry-run --debug
debug-install di: install

uninstall u:
	helm uninstall coder -n coder

# Manual service expose.
#
service-expose:
	kubectl expose service -n coder coder --type=NodePort --target-port=8080 --name=coder-server-ext

service-expose-delete:
	kubectl delete service -n coder coder-server-ext

# Common cluster commands.
#
get-all ga:
	kubectl get all -n coder

get-events ge:
	kubectl get events --sort-by=".metadata.managedFields[0].time" -n coder

help: makester-help
	printf "\n(Makefile)\n"
	$(call help-line,get-all,Get all resources in the \"coder\" k8s namespace)
	$(call help-line,get-events,Get events in the \"coder\" k8s namespace)
	$(call help-line,install,Install offline-coder \"$(MAKESTER__IMAGE_TAG_ALIAS)\")
	$(call help-line,debug-install,Install (debug mode) offline-coder \"$(MAKESTER__IMAGE_TAG_ALIAS)\")
	$(call help-line,uninstall,Uninstall offline-coder)
	$(MAKE) container-images-help
	$(MAKE) terraform-providers-help
