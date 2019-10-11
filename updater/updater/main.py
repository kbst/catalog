import logging

from catalog import Catalog

from entry import Entry


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)

    catalog = Catalog()
    for entry_name in catalog.get_entries():
        Entry(catalog, entry_name).check_releases()
    catalog.repo.close()
