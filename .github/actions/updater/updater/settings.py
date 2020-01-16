from os import getenv

CATALOG_NAME = getenv('CATALOG_NAME', 'catalog')
CATALOG_REF = getenv('CATALOG_REF', 'master')

GITHUB_ACTOR = getenv('GITHUB_ACTOR', None)
GITHUB_TOKEN = getenv('INPUT_GITHUB_TOKEN', None)

CATALOG_URL = getenv('CATALOG_URL', 'github.com/kbst/catalog.git')
if GITHUB_ACTOR and GITHUB_TOKEN:
    CATALOG_URL = f'{GITHUB_ACTOR}:{GITHUB_TOKEN}@{CATALOG_URL}'
CATALOG_URL = f'https://{CATALOG_URL}'

GIT_USER_NAME = getenv('GIT_USER_NAME', 'Catalog Updater')
GIT_USER_EMAIL = getenv('GIT_USER_EMAIL', 'catalog-updater@ghactions')
