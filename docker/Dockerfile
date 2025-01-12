# syntax=docker/dockerfile:1.4

ARG CODER_RELEASE=latest
FROM ghcr.io/coder/coder:${CODER_RELEASE} AS builder

USER root

# For offline Coder deployments, we'll configure a filesystem mirror.
# to download the Terraform providers used in Coder templates.
#  We can seed this at build-time or by mounting a volume to
#  /opt/terraform/plugins in the container.
#  https://developer.hashicorp.com/terraform/cli/config/config-file#filesystem_mirror
#  Be sure to add all the providers you use in your templates to /opt/terraform/plugins
#
ARG ARCH=arm64
ARG UNAME=darwin

ARG CODER_PROVIDER_VERSION=2.1.0
WORKDIR /home/coder/.terraform.d/plugins/registry.terraform.io/coder/coder
COPY docker/resources/terraform-provider-coder_${CODER_PROVIDER_VERSION}_${UNAME}_${ARCH}.zip .

ARG DOCKER_PROVIDER_VERSION=3.0.2
WORKDIR /home/coder/.terraform.d/plugins/registry.terraform.io/kreuzwerker/docker
COPY docker/resources/terraform-provider-docker_${DOCKER_PROVIDER_VERSION}_${UNAME}_${ARCH}.zip .

ARG KUBERNETES_PROVIDER_VERSION=2.35.1
WORKDIR /home/coder/.terraform.d/plugins/registry.terraform.io/hashicorp/kubernetes
COPY docker/resources/terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_${UNAME}_${ARCH}.zip .

#ARG CODER_ENVBUILDER_PROVIDER_VERSION=1.0.0
#WORKDIR /home/coder/.terraform.d/plugins/registry.terraform.io/hashicorp/kubernetes
#COPY docker/resources/terraform-provider-envbuilder_${CODER_ENVBUILDER_PROVIDER_VERSION}_${UNAME}_${ARCH}.zip .

WORKDIR /home/coder/
COPY docker/resources/filesystem-mirror-example.tfrc .terraformrc

RUN chown -R coder:coder .terraform*

USER coder

# Use the .terraformrc file to inform Terraform of the locally installed providers.
ENV TF_CLI_CONFIG_FILE=/home/coder/.terraformrc
