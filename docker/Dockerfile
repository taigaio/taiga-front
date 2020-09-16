FROM nginx:1.19-alpine
LABEL maintainer="support@taiga.io"

RUN apk update \
    && wget https://github.com/taigaio/taiga-front-dist/archive/master.zip \
    && unzip master.zip \
    && mv taiga-front-dist-master/dist/* /usr/share/nginx/html \
    && rm -rf taiga-front-dist-master
