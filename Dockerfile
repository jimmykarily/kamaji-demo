ARG BASE_IMAGE=ubuntu:24.04

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

 RUN apt-get update && apt-get install -y curl apparmor-utils

COPY config.toml /etc/containerd/config.toml
COPY scripts/* /opt/kubeadm/scripts/
COPY setup-kube-admin.sh /setup-kube-admin.sh
COPY --from=provider-builder /workspace/agent-provider-kubeadm /system/providers/agent-provider-kubeadm

RUN /setup-kube-admin.sh
RUN rm /setup-kube-admin.sh

COPY --from=kairos-init /kairos-init /kairos-init
RUN /kairos-init -l debug --version $VERSION
RUN /kairos-init validate
RUN rm /kairos-init