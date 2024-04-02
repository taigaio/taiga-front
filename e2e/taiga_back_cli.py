# -*- coding: utf-8 -*-
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC

"""
This script assumes:
 - Your taiga-back virtualenv is activated
 - click is installed in that virtualenv (pip install click)
"""

import os
import django
import click
import sys

def _configure_environment(taiga_back_path):
    sys.stderr = open('/dev/null', 'w')
    sys.path.append(taiga_back_path)
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")
    django.setup()
    globals()["taiga"] = __import__("taiga")
    from django.conf import settings
    settings.EMAIL_BACKEND = 'django.core.mail.backends.dummy.EmailBackend'

@click.group()
def cli():
    pass

@cli.command()
@click.argument("taiga_back_path", nargs=1, type=click.STRING)
@click.argument("project", nargs=1, type=click.STRING)
@click.argument("user", nargs=1, type=click.STRING)
@click.option("--reason", type=click.STRING, help="Postal code of the customer (5 digits)")
def transfer_token(taiga_back_path, project, user, reason):
    """
    Generates the transfer token for the specified project and user (the reason parameter is optional).\n
    As first argument you must specify the taiga-path.
    """
    _configure_environment(taiga_back_path)
    project = taiga.projects.models.Project.objects.get(slug=project)
    user = taiga.users.models.User.objects.get(username=user)
    taiga.projects.services.start_project_transfer(project, user, reason)
    print(project.transfer_token)


@cli.command()
@click.argument("taiga_back_path", nargs=1, type=click.STRING)
@click.argument("user", nargs=1, type=click.STRING)
@click.option("--max_private_projects", type=click.STRING, help="Max number of private projects")
@click.option("--max_memberships_private_projects", type=click.STRING, help="Max number of memberships in private projects")
@click.option("--max_public_projects", type=click.STRING, help="Max number of public projects")
@click.option("--max_memberships_public_projects", type=click.STRING, help="Max number of memberships in public projects")
def update_user_limits(taiga_back_path, user, max_private_projects, max_memberships_private_projects, max_public_projects, max_memberships_public_projects):
    """
    Updates the user project limits for user.\n
    As first argument you must specify the taiga-path.
    """
    _configure_environment(taiga_back_path)
    user = taiga.users.models.User.objects.get(username=user)
    user.max_private_projects = max_private_projects
    user.max_memberships_private_projects = max_memberships_private_projects
    user.max_public_projects = max_public_projects
    user.max_memberships_public_projects = max_memberships_public_projects
    user.save()


if __name__ == "__main__":
    cli()
