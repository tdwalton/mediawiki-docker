FROM debian:sid
MAINTAINER Gabriel Wicke <gwicke@wikimedia.org>

# Waiting in antiticipation for built-time arguments
# https://github.com/docker/docker/issues/14634
ENV MEDIAWIKI_VERSION REL1_27

# XXX: Consider switching to nginx.
RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-cli \
        php5-gd \
        php5-curl \
        imagemagick \
        netcat \
       git \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/archives/* \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_http \
    # Remove the default Debian index page.
    && rm /var/www/html/index.html


# MediaWiki setup
RUN set -x; \
    mkdir -p /usr/src \
    && git clone \
        --depth 1 \
        -b $MEDIAWIKI_VERSION \
        https://gerrit.wikimedia.org/r/p/mediawiki/core.git \
       /var/www/html \
#    && cd /var/www/html \
#    && git submodule update --init skins \
#    && git submodule update --init vendor \
#    && cd extensions \
#    # VisualEditor
#    # TODO: make submodules shallow clones?
#    && git submodule update --init VisualEditor \
#    && cd VisualEditor \
#    && git checkout $MEDIAWIKI_VERSION \
#    && git submodule update --init
    && git clone \
        --depth 1 \
        -b $MEDIAWIKI_VERSION \
        https://gerrit.wikimedia.org/r/p/mediawiki/vendor.git \
        /var/www/html/vendor

COPY php.ini /usr/local/etc/php/conf.d/mediawiki.ini

COPY apache/mediawiki.conf /etc/apache2/
RUN echo "Include /etc/apache2/mediawiki.conf" >> /etc/apache2/apache2.conf

COPY docker-entrypoint.sh /entrypoint.sh

#add some tools for debugging image
#RUN ["apt-get", "update"]
#RUN ["apt-get", "install", "-y", "vim"]
#RUN ["apt-get", "install", "-y", "curl"]

EXPOSE 80 443
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apachectl", "-e", "info", "-D", "FOREGROUND"]
