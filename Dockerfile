ARG BASE_IMAGE=ubuntu:22.04

FROM quay.io/kairos/kairos-init:v0.5.0 AS kairos-init

# Build the provider binary
FROM golang:1.24-alpine AS provider-builder
RUN apk add --no-cache git
WORKDIR /workspace
RUN git clone https://github.com/kairos-io/provider-kubeadm.git .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o agent-provider-kubeadm .

FROM ${BASE_IMAGE} AS base-kairos
ARG VARIANT=core
ARG MODEL=generic
ARG TRUSTED_BOOT=false
ARG VERSION=v0.0.1

COPY config.toml /etc/containerd/config.toml
COPY scripts/* /opt/kubeadm/scripts/
COPY setup-kube-admin.sh /setup-kube-admin.sh

RUN /setup-kube-admin.sh
RUN rm /setup-kube-admin.sh

COPY --from=kairos-init /kairos-init /kairos-init
# Copy the provider binary
COPY --from=provider-builder /workspace/agent-provider-kubeadm /system/providers/agent-provider-kubeadm
RUN /kairos-init -l debug -s install -m "${MODEL}" -v "${VARIANT}" -t "${TRUSTED_BOOT}" -k "${KUBERNETES_DISTRO}" --k8sversion "${KUBERNETES_VERSION}" --version "${VERSION}"
RUN /kairos-init -l debug -s init -m "${MODEL}" -v "${VARIANT}" -t "${TRUSTED_BOOT}" -k "${KUBERNETES_DISTRO}" --k8sversion "${KUBERNETES_VERSION}" --version "${VERSION}"
RUN /kairos-init validate
RUN rm /kairos-init
