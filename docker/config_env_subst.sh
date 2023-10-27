#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL

contribs=()

# Lowercase and set environment variables

# Check and set the PUBLIC_REGISTER_ENABLED variable
if [[ "${PUBLIC_REGISTER_ENABLED}" == "True" || "${PUBLIC_REGISTER_ENABLED}" == "true" ]]; then
    export PUBLIC_REGISTER_ENABLED="true"
else
    export PUBLIC_REGISTER_ENABLED="false"
fi

# Check and set the ENABLE_GITLAB_AUTH variable
if [[ "${ENABLE_GITLAB_AUTH}" == "True" || "${ENABLE_GITLAB_AUTH}" == "true" ]]; then
    export ENABLE_GITLAB_AUTH="true"
else
    export ENABLE_GITLAB_AUTH="false"
fi

# Check and set the ENABLE_GITHUB_AUTH variable
if [[ "${ENABLE_GITHUB_AUTH}" == "True" || "${ENABLE_GITHUB_AUTH}" == "true" ]]; then
    export ENABLE_GITHUB_AUTH="true"
else
    export ENABLE_GITHUB_AUTH="false"
fi

# Check and set the ENABLE_GITHUB_IMPORTER variable
if [[ "${ENABLE_GITHUB_IMPORTER}" == "True" || "${ENABLE_GITHUB_IMPORTER}" == "true" ]]; then
    export ENABLE_GITHUB_IMPORTER="true"
else
    export ENABLE_GITHUB_IMPORTER="false"
fi

# Check and set the ENABLE_JIRA_IMPORTER variable
if [[ "${ENABLE_JIRA_IMPORTER}" == "True" || "${ENABLE_JIRA_IMPORTER}" == "true" ]]; then
    export ENABLE_JIRA_IMPORTER="true"
else
    export ENABLE_JIRA_IMPORTER="false"
fi

# Check and set the ENABLE_TRELLO_IMPORTER variable
if [[ "${ENABLE_TRELLO_IMPORTER}" == "True" || "${ENABLE_TRELLO_IMPORTER}" == "true" ]]; then
    export ENABLE_TRELLO_IMPORTER="true"
else
    export ENABLE_TRELLO_IMPORTER="false"
fi

# Check and set the ENABLE_SLACK variable
if [[ "${ENABLE_SLACK}" == "True" || "${ENABLE_SLACK}" == "true" ]]; then
    export ENABLE_SLACK="true"
else
    export ENABLE_SLACK="false"
fi

# Public registration and oauth
if [ ${PUBLIC_REGISTER_ENABLED} == "true" ]; then
    # Include GitHub authentication plugin if enabled
    if [ ${ENABLE_GITHUB_AUTH} == "true" ]; then
        contribs+=('"plugins/github-auth/github-auth.json"')
    fi
    # Include GitLab authentication plugin if enabled
    if [ ${ENABLE_GITLAB_AUTH} == "true" ]; then
        contribs+=('"plugins/gitlab-auth/gitlab-auth.json"')
    fi
fi

# Include Slack plugin if enabled
if [ ${ENABLE_SLACK} == "true" ]; then
    contribs+=('"plugins/slack/slack.json"')
fi

# Convert array to a comma-separated string
contribs=$( IFS=,; echo "[${contribs[*]}]" )

# Set CONTRIB_PLUGINS environment variable
export CONTRIB_PLUGINS=$contribs

# Check if the configuration file exists, and if not, create it
FILE=/usr/share/nginx/html/conf.json
if [ ! -f "$FILE" ]; then
    envsubst < /usr/share/nginx/html/conf.json.template \
             > /usr/share/nginx/html/conf.json
fi

# Update base href in the HTML file
sed -i 's;<base href="/">;<base href="'"${TAIGA_SUBPATH}/"'">;g' /usr/share/nginx/html/index.html