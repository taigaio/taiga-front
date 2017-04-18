##############################################################
##
##
##  Taiga-front
##
##
###############################################################

FROM nginx

COPY taiga-front-dist/dist /taiga
COPY conf.json /taiga/conf.json
COPY run.sh /taiga/run.sh
COPY nginx.conf /etc/nginx/nginx.conf
COPY taiga.conf /etc/nginx/conf.d/default.conf

RUN chmod -R 755 /taiga && chmod +x /taiga/run.sh

CMD ["/taiga/run.sh"]
