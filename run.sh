#! /usr/bin/env bash

sed -i "s/API_SERVER/$API_NAME/g" /taiga/conf.json

nginx -g "daemon off;"
