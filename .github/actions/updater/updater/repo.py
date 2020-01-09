import logging
from os import path

from git import Repo
from git.exc import GitCommandError

REPO_DIR = path.abspath('repos')


def clone_or_reset_repo(name, url, ref='master'):
    logging.debug(f'start cloning or resetting {url}')
    repo_path = path.join(REPO_DIR, name)
    repo = Repo.init(repo_path)

    try:
        repo.delete_remote('origin')
    except GitCommandError:
        pass
    finally:
        repo.create_remote('origin', url)

    repo.git.fetch('--tags', 'origin')
    repo.git.checkout('-f', f'origin/{ref}')
    repo.git.reset('--hard', f'origin/{ref}')
    logging.debug(f'finished cloning or resetting {url}')
    return repo
