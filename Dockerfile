# wunder/fuzzy-alpine-nginxphpfpm
#
# VERSION v1.12.1

FROM quay.io/wunder/fuzzy-alpine-base:v3.6
MAINTAINER james.nesbitt@wunder.io

RUN apk --no-cache --update add nginx && \
    # Cleanup
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Make our nginx.conf available on the container.
ADD etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD etc/nginx/conf.d /etc/nginx/conf.d

# Separate the logs into their own volume to keep them out of the container.
VOLUME ["/var/log/nginx"]

# Expose the HTTP and HTTPS ports.
EXPOSE 80 443

####
# Install php7 packages from edge repositories
#
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    apk --no-cache --update add \
        php7-fpm \
        php7-apcu \
        php7-common \
        php7-curl \
        php7-memcached \
        php7-xml \
        php7-xmlrpc \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-pdo_sqlite \
        php7-mysqlnd \
        php7-mysqli \
        php7-mcrypt \
        php7-opcache \
        php7-json \
        php7-pear \
        php7-mbstring \
        php7-soap \
        php7-ctype \
        php7-gd \
        php7-dom \
        php7-bcmath \
        php7-gmagick && \
    # Cleanup
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

####
# Add a www php-fpm service definition
#
ADD etc/php7/php-fpm.d/www.conf /etc/php7/php-fpm.d/www.conf

####
# Add php settings and extension control from Wunder
#
ADD etc/php7/conf.d/90_wunder.ini /etc/php7/conf.d/90_wunder.ini

####
# Some default ENV values
#
ENV HOSTNAME phpfpm7
ENV ENVIRONMENT develop

####
# Add Drupal 8 specific folder structure so that it has correct permissions when it is volumized.
#
# @DEPRECATED based on use-case, this could be avoided.
#
# RUN mkdir -p /app/web/sites/default/files && \
# chown -R app:app /app

# Expose the php port
EXPOSE 9000

####
# Install monit
#
RUN apk --no-cache --update add \
    monit && \
    # Cleanup
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

ADD etc/monitrc /etc/monitrc
ADD usr/sbin/monit_entrypoint /usr/sbin/monit_entrypoint
ADD etc/monit.d /etc/monit.d

# Set our custom entrypoint script as the entrypoint.
ENTRYPOINT ["/usr/sbin/monit_entrypoint", "start"]
