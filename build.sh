#!/usr/bin/env bash
source /etc/profile.d/build-env.sh
BUILD_ASSETS_DIR=${BUILD_ASSETS_DIR}
BUILD_ROOT_DIR=${BUILD_ROOT_DIR}
BUILD_PREFIX_DIR=${BUILD_PREFIX_DIR}

LIBMAXMINDDB_VERSION=${LIBMAXMINDDB_VERSION}
LIBICONV_VERSION=${LIBICONV_VERSION}
LIBZIP_VERSION=${LIBZIP_VERSION}
NGHTTP2_VERSION=${NGHTTP2_VERSION}
CURL_VERSION=${CURL_VERSION}
PHP_VERSION=${PHP_VERSION}

build_pecl() {
    local package=${1}
    local configure_line=${2}
    pecl download ${package}
    mkdir php-${package}
    tar xf ${package}-*.tgz -C php-${package} --strip=1
    ( cd php-${package} && phpize && ./configure ${configure_line} && make -j$(nproc) && make install INSTALL_ROOT=${BUILD_ROOT_DIR} )
}

set -e

cd ${BUILD_ASSETS_DIR}

download_and_extract http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz libiconv && ( cd libiconv && ./configure --prefix=/usr && make -j$(nproc) && make install DESTDIR=${BUILD_ROOT_DIR} )
download_and_extract https://github.com/tatsuhiro-t/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.bz2 nghttp2 && ( cd nghttp2 && ./configure --prefix=/usr && make -j$(nproc) && make install DESTDIR=${BUILD_ROOT_DIR} && make install && ldconfig )
download_and_extract http://curl.haxx.se/download/curl-${CURL_VERSION}.tar.bz2 curl && ( cd curl && ./configure --prefix=/usr --without-nss --with-ssl --with-libssh2 --with-nghttp2=${BUILD_ROOT_DIR}/usr --disable-ipv6 && make -j$(nproc) && make install DESTDIR=${BUILD_ROOT_DIR} && ldconfig )
download_and_extract https://libzip.org/download/libzip-${LIBZIP_VERSION}.tar.gz libzip && ( cd libzip && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=${BUILD_PREFIX_DIR} && make && make install ) && ldconfig
download_and_extract https://github.com/maxmind/libmaxminddb/releases/download/${LIBMAXMINDDB_VERSION}/libmaxminddb-${LIBMAXMINDDB_VERSION}.tar.gz libmaxminddb && ( cd libmaxminddb && ./configure --prefix=/usr && make -j$(nproc) && make install DESTDIR=${BUILD_ROOT_DIR} ) && ldconfig

download_and_extract https://www.php.net/distributions/php-${PHP_VERSION}.tar.bz2 php && ( cd php && \
    ./configure --prefix=/usr --with-config-file-path=/usr/etc --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=${BUILD_PREFIX_DIR} --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-sysvshm --enable-inline-optimization --with-curl=${BUILD_PREFIX_DIR} --enable-mbregex --enable-fpm --enable-mbstring --with-gd --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-soap --with-bz2 --with-gmp --with-gettext --with-readline --enable-sockets --enable-calendar --enable-opcache --with-sodium --enable-zip --with-libzip=${BUILD_PREFIX_DIR} \
    && make -j$(nproc) ZEND_EXTRA_LIBS='-liconv' && make install && make install INSTALL_ROOT=${BUILD_ROOT_DIR} )

build_pecl apcu
build_pecl redis
git clone https://github.com/acgrid/php-ext-bencode.git && ( cd php-ext-bencode && phpize && ./configure && make -j$(nproc) && make install INSTALL_ROOT=${BUILD_ROOT_DIR} )
git clone https://github.com/maxmind/MaxMind-DB-Reader-php.git && ( cd MaxMind-DB-Reader-php/ext/ && phpize && ./configure --with-maxminddb=${BUILD_PREFIX_DIR} && make -j$(nproc) && make install INSTALL_ROOT=${BUILD_ROOT_DIR} )

set +e
strip_debug "${BUILD_PREFIX_DIR}/bin/" "*"
strip_debug "${BUILD_PREFIX_DIR}/sbin/" "*"
strip_debug "${BUILD_PREFIX_DIR}/lib/" "*.so"
strip_debug "${BUILD_PREFIX_DIR}/lib/" "*.so.*"

rm -rf ${BUILD_PREFIX_DIR}/share/man
rm -rf ${BUILD_PREFIX_DIR}/share/include
rm -rf ${BUILD_PREFIX_DIR}/lib/pkgconfig