FROM python:3.8 as base

#
#
# tmp image to handle kustomize changing release artifacts
FROM base as tmp

ARG KUSTOMIZE_VERSION=4.4.0

WORKDIR /tmp

# Reject kustomize versions before 3.2.1
RUN if dpkg --compare-versions "$KUSTOMIZE_VERSION" "lt" "3.2.1"; then \
  echo "kustomize versions lower than 3.2.1 not supported" && \
  exit; \
  fi

# Handle kustomize versions before 3.3.0
# distributed as binaries
RUN if dpkg --compare-versions "$KUSTOMIZE_VERSION" "lt" "3.3.0"; then \
  KUSTOMIZE_BINARY_PATH="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_kustomize.v${KUSTOMIZE_VERSION}_linux_amd64"; \
  curl -Lso /usr/local/bin/kustomize ${KUSTOMIZE_BINARY_PATH} && \
  chmod +x /usr/local/bin/kustomize && \
  kustomize version; \
  fi

# Handle kustomize versions after 3.3.0
# distributed as tar files
RUN if dpkg --compare-versions "$KUSTOMIZE_VERSION" "ge" "3.3.0"; \
  then \
  KUSTOMIZE_BINARY_PATH="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz"; \
  curl -LOs ${KUSTOMIZE_BINARY_PATH} && \
  tar -xf kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
  mv kustomize /usr/local/bin/kustomize && \
  chmod +x /usr/local/bin/kustomize && \
  kustomize version; \
  fi

#
#
# final image
FROM base

COPY Pipfile Pipfile.lock /opt/
WORKDIR /opt

RUN pip install --no-cache-dir pipenv &&\
  PIPENV_VENV_IN_PROJECT=true pipenv install

COPY test.py /opt/test/test.py

COPY --from=tmp /usr/local/bin/kustomize /usr/local/bin/kustomize

ENV PATH=/opt/.venv/bin:$PATH

WORKDIR /opt/test
CMD ["nosetests", "-s", "test.py"]
