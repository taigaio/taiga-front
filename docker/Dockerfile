FROM nginx:1.19-alpine
LABEL maintainer="support@taiga.io"

COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY docker/conf.json.template /
COPY docker/config_env_subst.sh /docker-entrypoint.d/30_config_env_subst.sh

RUN apk update \
    && apk add --no-cache --virtual .build-deps \
       subversion \
    # Install taiga-front core
    && wget https://github.com/taigaio/taiga-front-dist/archive/master.zip \
    && unzip master.zip \
    && mv /conf.json.template taiga-front-dist-master/dist/ \
    && chmod +x /docker-entrypoint.d/30_config_env_subst.sh \
    # Install taiga-front contribs
    && mkdir taiga-front-dist-master/dist/plugins \
    && cd taiga-front-dist-master/dist/plugins \
    && svn export "https://github.com/taigaio/taiga-contrib-slack/tags/5.5.1/front/dist" "slack" \
    && cd / \
    # Remove unused dependencies
    && apk del --no-cache .build-deps \
    && rm master.zip \
    # Ready for nginx
    && mv taiga-front-dist-master/dist/* /usr/share/nginx/html \
    && rm -rf taiga-front-dist-master
