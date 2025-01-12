.SILENT:
ifndef .DEFAULT_GOAL
.DEFAULT_GOAL := container-images-help
endif

image-pull-into-docker:
	$(info ### Pulling local registry image $(MAKESTER__SERVICE_NAME):$(HASH) into docker)
	$(MAKESTER__DOCKER) pull $(MAKESTER__SERVICE_NAME):$(HASH)

image-tag-in-docker: image-pull-into-docker
	$(info ### Tagging local registry image $(MAKESTER__SERVICE_NAME):$(HASH) => $(MAKESTER__STATIC_SERVICE_NAME):$(HASH))
	$(MAKESTER__DOCKER) tag $(MAKESTER__SERVICE_NAME):$(HASH) $(MAKESTER__STATIC_SERVICE_NAME):$(HASH)

image-transfer: image-tag-in-docker
	$(info ### Deleting pulled image $(MAKESTER__SERVICE_NAME):$(HASH))
	$(MAKESTER__DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH)

multi-arch-buildx-test: image-registry-start image-buildx-builder
	$(MAKE) multi-arch-buildx
	$(MAKE) image-transfer
	$(MAKE) image-registry-stop

multi-arch-buildx:
	$(MAKESTER__DOCKER) buildx ls
	$(MAKE) MAKESTER__DOCKER_DRIVER_OUTPUT=push MAKESTER__DOCKER_PLATFORM=linux/arm64,linux/amd64 image-buildx

amd-arch-buildx: PLATFORM := linux/amd64
arm-arch-buildx: PLATFORM := linux/arm64
amd-arch-buildx arm-arch-buildx: _arch-buildx

_arch-buildx:
	$(MAKE) image-buildx-builder
	$(MAKESTER__DOCKER) buildx ls
	$(MAKE) MAKESTER__DOCKER_DRIVER_OUTPUT=push MAKESTER__DOCKER_PLATFORM=$(PLATFORM) image-buildx

_image-export:
	$(info ### Export the "$(MAKESTER__IMAGE_TAG_ALIAS)" from the local Docker daemon ...)
	$(MAKESTER__DOCKER) save $(MAKESTER__SERVICE_NAME) > $(MAKESTER__PROJECT_NAME).tar

_image-vm-copy:
ifeq ($(MAKESTER__UNAME), Darwin)
	$(info ### Transfer "$(MAKESTER__SERVICE_NAME)" into microk8s-vm ...)
	multipass transfer $(MAKESTER__PROJECT_NAME).tar microk8s-vm:$(MAKESTER__PROJECT_NAME).tar
endif

_local-image-vm-del:
ifeq ($(MAKESTER__UNAME), Darwin)
	$(info ### Deleting "$(MAKESTER__SERVICE_NAME)" from microk8s-vm ...)
	multipass exec microk8s-vm -- rm $(MAKESTER__PROJECT_NAME).tar
endif

image-cache-add: _image-export _image-vm-copy
	$(info ### Inject "$(MAKESTER__SERVICE_NAME)" into the MicroK8s image cache ...)
	$(MAKESTER__MICROK8S) ctr image import $(MAKESTER__PROJECT_NAME).tar
	$(MAKE) _local-image-vm-del
	$(shell which rm) $(MAKESTER__PROJECT_NAME).tar

image-cache-del:
	$(info ### Deleting "$(MAKESTER__SERVICE_NAME)" from MicroK8s image cache ...)
	$(MAKESTER__MICROK8S) ctr images delete $(MAKESTER__IMAGE_TAG_ALIAS)

_image-rm:
	$(MAKESTER__DOCKER) rmi $(MAKESTER__SERVICE_NAME):latest

image-rm: _image-rm

container-images-help:
	printf "\n(makefiles/container-images.mk)\n"
	$(call help-line,image-cache-add,Inject \"$(MAKESTER__IMAGE_TAG_ALIAS)\" into the MicroK8s image cache)
	$(call help-line,image-cache-del,Delete \"$(MAKESTER__IMAGE_TAG_ALIAS)\" from the MicroK8s image cache)
	$(call help-line,local-image-buildx,Container image build for local platform)
	$(call help-line,multi-arch-buildx,Multi-platform container image build for \"$(MAKESTER__IMAGE_TAG_ALIAS)\")
	$(call help-line,multi-arch-buildx-test,Shake-out multi-platform container image build locally)

.PHONY: container-images-help
