FROM python:3.8 as tfbeta

RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    unzip

RUN mkdir -p /opt/bin

ARG TERRAFORM_VERSION=0.15.0-rc2
RUN echo "TERRAFORM_VERSION: ${TERRAFORM_VERSION}" \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /opt/bin \
    && chmod +x /opt/bin/terraform \
    && /opt/bin/terraform version


FROM kubestack/framework:v0.12.2-beta.0-kind

COPY --from=tfbeta /opt/bin/terraform /opt/bin/terraform

COPY Pipfile Pipfile.lock /opt/
WORKDIR /opt

RUN pip install --no-cache-dir pipenv &&\
    PIPENV_VENV_IN_PROJECT=true pipenv install

COPY main.tf.tpl test.py .terraformrc /opt/test/
COPY test-files /opt/test/test-files

ENV PATH=/opt/.venv/bin:$PATH \
    KUBECONFIG=/opt/test/.kubeconfig \
    TF_CLI_CONFIG_FILE=/opt/test/.terraformrc

WORKDIR /opt/test
CMD ["nosetests", "-s", "--logging-level", "WARNING", "test.py"]
