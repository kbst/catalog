from os import getenv

CATALOG_NAME = getenv('CATALOG_NAME', 'catalog')
CATALOG_URL = getenv('CATALOG_URL', 'https://github.com/kbst/catalog.git')
CATALOG_REF = getenv('CATALOG_REF', 'master')
