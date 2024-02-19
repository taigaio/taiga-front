# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL

FROM nginx:1.23-alpine
LABEL maintainer="support@taiga.io"

COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY docker/conf.json.template /
COPY docker/config_env_subst.sh /docker-entrypoint.d/30_config_env_subst.sh

RUN set -eux; \
    apk update; \
    apk add --no-cache --virtual .build-deps \
       subversion; \
    apk add \
       bash; \
    # Install taiga-front core
    wget https://github.com/kaleidos-ventures/taiga-front-dist/archive/6.7.3.zip -O source.zip; \
    unzip source.zip; \
    mv /taiga-front-dist-6.7.3 /taiga; \
    mv /conf.json.template taiga/dist/; \
    chmod +x /docker-entrypoint.d/30_config_env_subst.sh; \
    # Install taiga-front contribs
    mkdir /taiga/dist/plugins; \
    cd /taiga/dist/plugins; \
    # Slack
    wget https://github.com/kaleidos-ventures/taiga-contrib-slack/archive/6.7.0.zip -O source.zip; \
    unzip -j source.zip "taiga-contrib-slack-6.7.0/front/dist/*" -d slak; \
    rm source.zip; \
    # Github
    wget http://github.com/kaleidos-ventures/taiga-contrib-github-auth/archive/6.7.0.zip -O source.zip; \
    unzip -j source.zip "taiga-contrib-github-auth-6.7.0/front/dist/*" -d github-auth; \
    rm source.zip; \
    # Gitlab
    wget http://github.com/kaleidos-ventures/taiga-contrib-gitlab-auth/archive/6.7.1.zip -O source.zip; \
    unzip -j source.zip "taiga-contrib-gitlab-auth-6.7.1/front/dist/*" -d gitlab-auth; \
    rm source.zip; \
    cd /; \
    # Remove unused dependencies
    apk del --no-cache .build-deps; \
    rm source.zip; \
    # Ready for nginx
    mv /taiga/dist/* /usr/share/nginx/html; \
    rm -rf /taiga
