#!/bin/bash

contribs=()

# Slack
if [[ -z "${ENABLE_SLACK}" ]]; then
    export ENABLE_SLACK="false"
fi

if [ ${ENABLE_SLACK} == "true" ]; then
    contribs+=('"/plugins/slack/slack.json"')
fi

# Public registration and oauth
if [[ -z "${PUBLIC_REGISTER_ENABLED}" ]]; then
    export PUBLIC_REGISTER_ENABLED="false"
fi

if [ ${PUBLIC_REGISTER_ENABLED} == "true" ]; then
    if [ ${ENABLE_GITHUB_AUTH} == "true" ]; then
        contribs+=('"/plugins/github-auth/github-auth.json"')
    fi
    if [ ${ENABLE_GITLAB_AUTH} == "true" ]; then
        contribs+=('"/plugins/gitlab-auth/gitlab-auth.json"')
    fi
fi

# Importers
if [[ -z "${ENABLE_GITHUB_IMPORTER}" ]]; then
    export ENABLE_GITHUB_IMPORTER="false"
fi

if [[ -z "${ENABLE_JIRA_IMPORTER}" ]]; then
    export ENABLE_JIRA_IMPORTER="false"
fi

if [[ -z "${ENABLE_TRELLO_IMPORTER}" ]]; then
    export ENABLE_TRELLO_IMPORTER="false"
fi

contribs=$( IFS=,; echo "[${contribs[*]}]" )

export CONTRIB_PLUGINS=$contribs

FILE=/usr/share/nginx/html/conf.json
if [ ! -f "$FILE" ]; then
    envsubst < /usr/share/nginx/html/conf.json.template \
             > /usr/share/nginx/html/conf.json
fi
