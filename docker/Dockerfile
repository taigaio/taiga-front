FROM nginx:1.19-alpine
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
    wget https://github.com/taigaio/taiga-front-dist/archive/6.0.10.zip -O source.zip; \
    unzip source.zip; \
    mv /taiga-front-dist-6.0.10 /taiga; \
    mv /conf.json.template taiga/dist/; \
    chmod +x /docker-entrypoint.d/30_config_env_subst.sh; \
    # Install taiga-front contribs
    mkdir /taiga/dist/plugins; \
    cd /taiga/dist/plugins; \
    svn export "https://github.com/taigaio/taiga-contrib-slack/tags/6.0.2/front/dist" "slack"; \
    svn export "https://github.com/taigaio/taiga-contrib-github-auth/tags/6.0.0/front/dist" "github-auth"; \
    svn export "https://github.com/taigaio/taiga-contrib-gitlab-auth/tags/6.0.0/front/dist" "gitlab-auth"; \
    cd /; \
    # Remove unused dependencies
    apk del --no-cache .build-deps; \
    rm source.zip; \
    # Ready for nginx
    mv /taiga/dist/* /usr/share/nginx/html; \
    rm -rf /taiga
