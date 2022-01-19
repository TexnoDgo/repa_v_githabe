FROM ubuntu:20.04
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone
RUN apt-get update && \
    apt-get install -y tzdata apache2 apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY index.html /var/www/html/
EXPOSE 80
ENTRYPOINT ["apache2ctl"]
CMD ["-DFOREGROUND"]
