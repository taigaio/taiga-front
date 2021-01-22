FROM nginx:1.19-alpine
LABEL maintainer="support@taiga.io"

COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY docker/conf.json.template /
COPY docker/config_env_subst.sh /docker-entrypoint.d/30_config_env_subst.sh

RUN set -eux; \
    apk update; \
    apk add --no-cache --virtual .build-deps \
       subversion; \
    # Install taiga-front core
    wget https://github.com/taigaio/taiga-front-dist/archive/master.zip; \
    unzip master.zip; \
    mv /taiga-front-dist-master /taiga-6; \
    mv /conf.json.template taiga-6/dist/; \
    chmod +x /docker-entrypoint.d/30_config_env_subst.sh; \
    # Install taiga-front contribs
    mkdir /taiga-6/dist/plugins; \
    cd /taiga-6/dist/plugins; \
    svn export "https://github.com/taigaio/taiga-contrib-slack/tags/5.5.1/front/dist" "slack"; \
    svn export "https://github.com/taigaio/taiga-contrib-github-auth/tags/3.1/front/dist" "github-auth"; \
    svn export "https://github.com/taigaio/taiga-contrib-gitlab-auth/tags/3.1.1/front/dist" "gitlab-auth"; \
    cd /; \
    # Remove unused dependencies
    apk del --no-cache .build-deps; \
    rm master.zip; \
    # Ready for nginx
    mv /taiga-6/dist/* /usr/share/nginx/html; \
    rm -rf /taiga-6
