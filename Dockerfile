FROM python:3

ARG KUSTOMIZE_VERSION=2.0.3

RUN curl -Lso /usr/local/bin/kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64 \
    && chmod +x /usr/local/bin/kustomize \
    && kustomize version
