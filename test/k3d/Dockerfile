FROM kubestack/framework:v0.19.1-beta.0-kind

COPY Pipfile Pipfile.lock /opt/
WORKDIR /opt

RUN pip install --no-cache-dir pipenv &&\
    PIPENV_VENV_IN_PROJECT=true pipenv install

COPY main.tf.tpl main.py /opt/test/

ENV PATH=/opt/.venv/bin:$PATH \
    KUBECONFIG=/opt/test/.kubeconfig \
    KUBECONFIG_PATH=/opt/test/.kubeconfig

WORKDIR /opt/test
ENTRYPOINT ["python", "main.py"]
