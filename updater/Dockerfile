FROM python:3

COPY Pipfile Pipfile.lock /opt/

WORKDIR /opt
RUN pip install --no-cache-dir pipenv &&\
    pipenv install

COPY repos /opt/repos
COPY updater /opt/updater

RUN ls -al /opt

CMD ["pipenv", "run", "python", "/opt/updater/main.py"]
