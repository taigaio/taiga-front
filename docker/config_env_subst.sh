#!/bin/bash

# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC

contribs=()

# Slack
if [[ -z "${ENABLE_SLACK}" ]]; then
    export ENABLE_SLACK="false"
fi

if [ ${ENABLE_SLACK} == "true" ]; then
    contribs+=('"plugins/slack/slack.json"')
fi

# Public registration and oauth
if [[ -z "${PUBLIC_REGISTER_ENABLED}" ]]; then
    export PUBLIC_REGISTER_ENABLED="false"
fi

if [ ${PUBLIC_REGISTER_ENABLED} == "true" ]; then
    if [ ${ENABLE_GITHUB_AUTH} == "true" ]; then
        contribs+=('"plugins/github-auth/github-auth.json"')
    fi
    if [ ${ENABLE_GITLAB_AUTH} == "true" ]; then
        contribs+=('"plugins/gitlab-auth/gitlab-auth.json"')
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

# Use the backend's language setting when supplied. Keep DEFAULT_LANGUAGE as
# a compatibility alias for existing frontend deployments.
if [[ -n "${LANGUAGE_CODE:-}" && -n "${DEFAULT_LANGUAGE:-}" &&
      "${LANGUAGE_CODE}" != "${DEFAULT_LANGUAGE}" ]]; then
    echo "LANGUAGE_CODE and DEFAULT_LANGUAGE must match" >&2
    exit 1
fi
export LANGUAGE_CODE="${LANGUAGE_CODE:-${DEFAULT_LANGUAGE:-en}}"

if [[ ! "$LANGUAGE_CODE" =~ ^[a-z]{2}(-[a-z0-9]+)*$ ]] ||
   ! compgen -G "/usr/share/nginx/html/v-*/locales/taiga/locale-${LANGUAGE_CODE}.json" > /dev/null; then
    echo "LANGUAGE_CODE is not a shipped frontend locale" >&2
    exit 1
fi

# The upstream image can contain an older prebuilt distribution. Offer the
# dark theme only after that distribution includes its compiled stylesheet.
TAIGA_THEMES_JSON='["taiga"]'
if compgen -G "/usr/share/nginx/html/v-*/styles/theme-taiga-dark.css" > /dev/null; then
    TAIGA_THEMES_JSON='["taiga", "taiga-dark"]'
fi
export TAIGA_THEMES_JSON

# Debug
if [[ -z "${DEBUG}" ]]; then
    export DEBUG="false"
fi

contribs=$( IFS=,; echo "[${contribs[*]}]" )

export CONTRIB_PLUGINS=$contribs

FILE=/usr/share/nginx/html/conf.json
if [ ! -f "$FILE" ]; then
    envsubst < /usr/share/nginx/html/conf.json.template \
             > /usr/share/nginx/html/conf.json
fi

sed -i 's;<base href="/">;<base href="'"${TAIGA_SUBPATH}/"'">;g' /usr/share/nginx/html/index.html
