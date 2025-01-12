.SILENT:
ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := container-images-help
endif

ifndef _UNAME
_UNAME ?= $(shell printf "%s" $(MAKESTER__UNAME) | tr '[:upper:]' '[:lower:]')
endif

ifndef _ARCH
_ARCH ?= $(MAKESTER__ARCH)
endif

ifndef DOCKER_PROVIDER_VERSION
DOCKER_PROVIDER_VERSION ?= 3.0.2
endif

# Coder envbuilder provider.
#
ifndef CODER_ENVBUILDER_PROVIDER_VERSION
CODER_ENVBUILDER_PROVIDER_VERSION := 1.0.0
endif

get-coder-envbuilder-provider: URL := https://github.com/coder/terraform-provider-envbuilder/releases/download/v${CODER_ENVBUILDER_PROVIDER_VERSION}/terraform-provider-envbuilder_${CODER_ENVBUILDER_PROVIDER_VERSION}_$(_UNAME)_$(_ARCH).zip
get-coder-envbuilder-provider:
	$(info ### Downloading Terraform Coder envbuilder provider ...)
	cd docker/resources; $(shell which curl) -LO $(URL)

# Coder provider.
#
ifndef CODER_PROVIDER_VERSION
CODER_PROVIDER_VERSION ?= 2.1.0
endif

get-coder-provider: URL := https://github.com/coder/terraform-provider-coder/releases/download/v${CODER_PROVIDER_VERSION}/terraform-provider-coder_${CODER_PROVIDER_VERSION}_$(_UNAME)_$(_ARCH).zip
get-coder-provider:
	$(info ### Downloading Terraform Coder provider ...)
	cd docker/resources; $(shell which curl) -LO $(URL)

# Kubernetes provider.
#
ifndef KUBERNETES_PROVIDER_VERSION
KUBERNETES_PROVIDER_VERSION ?= 2.35.1
endif

get-kubernetes-provider: URL := https://releases.hashicorp.com/terraform-provider-kubernetes/${KUBERNETES_PROVIDER_VERSION}/terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_$(_UNAME)_$(_ARCH).zip
get-kubernetes-provider:
	$(info ### Downloading Terraform Kubernetes provider ...)
	cd docker/resources; $(shell which curl) -LO $(URL)

# Docker provider.
#
ifndef DOCKER_PROVIDER_VERSION
DOCKER_PROVIDER_VERSION ?= 2.35.1
endif

get-docker-provider: URL := https://github.com/kreuzwerker/terraform-provider-docker/releases/download/v${DOCKER_PROVIDER_VERSION}/terraform-provider-docker_${DOCKER_PROVIDER_VERSION}_$(_UNAME)_$(_ARCH).zip
get-docker-provider:
	$(info ### Downloading Terraform Docker provider ...)
	cd docker/resources; $(shell which curl) -LO $(URL)

terraform-providers-help:
	printf "\n(makefiles/terraform-providers-help.mk)\n"
	$(call help-line,get-coder-envbuilder-provider,Download the Terraform Coder envbuilder provider \"$(CODER_ENVBUILDER_PROVIDER_VERSION)\")
	$(call help-line,get-coder-provider,Download the Terraform Coder provider \"$(CODER_PROVIDER_VERSION)\")
	$(call help-line,get-kubernetes-provider,Download the Terraform Kubernetes provider \"$(KUBERNETES_PROVIDER_VERSION)\")
	$(call help-line,get-docker-provider,Download the Terraform Docker provider \"$(DOCKER_PROVIDER_VERSION)\")
