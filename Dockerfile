FROM acgrid/multi-stage-builder AS builder

ARG PHP_VERSION=7.3.12
ARG LIBMAXMINDDB_VERSION=1.3.2
ARG LIBICONV_VERSION=1.16
ARG NGHTTP2_VERSION=1.40.0
ARG CURL_VERSION=7.67.0
ARG LIBZIP_VERSION=1.5.2

RUN yum install -y bzip2-devel \
    libjpeg-devel libpng-devel libjpeg-turbo-devel freetype-devel \
    libssh2-devel \
    libxml2-devel \
    gettext-devel \
    gmp-devel \
    openssl-devel \
    readline-devel \
    libsodium-devel

COPY build.sh .
RUN chmod +x build.sh && ./build.sh

FROM centos

ARG TZ
ENV TZ ${TZ:-Asia/Shanghai}
ENV TERM=linux \
    PHP_CONF_DIR=/usr/etc \
    COMPOSER_ALLOW_SUPERUSER=1

COPY --from=builder /var/lib/builder/rootfs /

RUN yum update -y && yum install -y epel-release tar bzip2 which && yum install -y libjpeg libpng libjpeg-turbo freetype libssh2 libxml2 gettext gmp openssl readline libsodium git && yum clean all

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN curl -L -o /usr/bin/phpunit https://phar.phpunit.de/phpunit-7.phar && chmod +x /usr/bin/phpunit

WORKDIR /usr/etc
RUN sed 's!;daemonize = yes!daemonize = no!g; s!;error_log = log/php-fpm.log!error_log = /dev/stderr!g' php-fpm.conf.default > php-fpm.conf && sed 's!listen = 127.0.0.1:9000!listen = 9000!g' php-fpm.d/www.conf.default > php-fpm.d/www.conf
ADD php.ini .

EXPOSE 9000

CMD php-fpm