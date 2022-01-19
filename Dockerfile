ARG apach_user_pass
ENV apach_user_pass ${apach_user_pass}
FROM ubuntu:20.04
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone
RUN apt-get update && \
    apt-get install -y tzdata apache2 apache2-utils whois  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    htpasswd -cb /etc/apache2/.htpasswd user1 $apach_user_pass
COPY index.html /var/www/html/
COPY 000-default.conf /etc/apache2/sites-enabled/
EXPOSE 80
ENTRYPOINT ["apache2ctl"]
CMD ["-DFOREGROUND"]
