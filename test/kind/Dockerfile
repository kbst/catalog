FROM kubestack/framework:v0.9.2-beta.0-kind

COPY Pipfile Pipfile.lock /opt/
WORKDIR /opt

RUN pip install --no-cache-dir pipenv &&\
    PIPENV_VENV_IN_PROJECT=true pipenv install

COPY main.tf test.py /opt/test/

ENV PATH=/opt/.venv/bin:$PATH \
    KUBECONFIG=/opt/test/.kubeconfig

WORKDIR /opt/test
CMD ["nosetests", "test.py"]
