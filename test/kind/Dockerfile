FROM kubestack/framework:v0.14.0-beta.1-kind

COPY Pipfile Pipfile.lock /opt/
WORKDIR /opt

RUN pip install --no-cache-dir pipenv &&\
    PIPENV_VENV_IN_PROJECT=true pipenv install

COPY main.tf.tpl test.py /opt/test/
COPY test-files /opt/test/test-files

ENV PATH=/opt/.venv/bin:$PATH \
    KUBECONFIG=/opt/test/.kubeconfig

WORKDIR /opt/test
CMD ["nosetests", "-s", "--logging-level", "WARNING", "test.py"]
