FROM debian:jessie


RUN echo "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20210326T030000Z jessie main" > /etc/apt/sources.list \
    && echo "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/20210326T030000Z jessie/updates main" >> /etc/apt/sources.list \
    && echo "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20210326T030000Z jessie-updates main" >> /etc/apt/sources.list \
    && echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list.d/jessie-backports.list \
    && sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    \
    && apt-get install -y --force-yes \
        libxml2-dev \
        libcurl4-openssl-dev \
        libjpeg-dev \
        libpng-dev \
        libxpm-dev \
        libmysqlclient-dev \
        libpq-dev \
        libicu-dev \
        libfreetype6-dev \
        libldap2-dev \
        libxslt-dev \
        libssl-dev \
        libldb-dev \
        build-essential \
        wget \
        flex \
        libcurl4-openssl-dev \
        libldb-dev \
        libldap2-dev \
        libexpat-dev \
        libbz2-dev \
        libc-client-dev \
        libkrb5-dev \
        libmcrypt-dev \
        libmhash-dev \
        curl \
        autoconf \
    && rm -r /var/lib/apt/lists/*

RUN cd /tmp \
    && curl -L https://github.com/openssl/openssl/releases/download/OpenSSL_0_9_8zh/openssl-0.9.8zh.tar.gz --output openssl-0.9.8zh.tar.gz \
    && tar xvfz openssl-0.9.8zh.tar.gz \
    && cd openssl-0.9.8zh \
    && ./config --prefix=/usr/local/openssl-0.9.8 \
    && make \
    && make install \
    && ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libpng.so /usr/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so.18 /usr/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libexpat.so /usr/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/libmysqlclient.so

RUN mkdir /opt/phpfcgi-4.4.9 \
    && mkdir /usr/local/src/php4-build \
    && cd /usr/local/src/php4-build \
    && wget http://de.php.net/get/php-4.4.9.tar.bz2/from/this/mirror -O php-4.4.9.tar.bz2 \
    && tar jxf php-4.4.9.tar.bz2 \
    && cd php-4.4.9/ \
    \
    && ./configure \
        --prefix=/opt/phpfcgi-4.4.9 \
        --with-pdo-pgsql \
        --with-zlib-dir \
        --enable-mbstring \
        --with-libxml-dir=/usr \
        --enable-soap \
        --enable-calendar \
        --with-curl \
        --with-mcrypt \
        --with-zlib \
        --with-gd \
        --with-pgsql \
        --disable-rpath \
        --enable-inline-optimization \
        --with-bz2 \
        --with-zlib \
        --enable-sockets \
        --enable-sysvsem \
        --enable-sysvshm \
        --enable-pcntl \
        --enable-mbregex \
        --with-mhash \
        --enable-zip \
        --with-pcre-regex \
        --with-mysql=/usr \
        --with-mysql-sock=/var/run/mysqld/mysqld.sock \
        --with-jpeg-dir=/usr \
        --with-png-dir=/usr \
        --enable-gd-native-ttf \
        --with-openssl=/usr/local/openssl-0.9.8 \
        --with-openssl-dir=/usr/local/openssl-0.9.8 \
        --with-libdir=/lib/x86_64-linux-gnu \
        --enable-ftp \
        --with-imap \
        --with-imap-ssl \
        --with-kerberos \
        --with-gettext \
        --with-expat-dir=/usr \
        --enable-fastcgi \
    && make \
    && make install \
    && cp /usr/local/src/php4-build/php-4.4.9/php.ini-recommended /opt/phpfcgi-4.4.9/lib/php.ini \
    \
    && cd /tmp \
    && wget http://pecl.php.net/get/APC-3.0.19.tgz \
    && tar xvfz APC-3.0.19.tgz \
    && cd APC-3.0.19 \
    && /opt/phpfcgi-4.4.9/bin/phpize \
    && ./configure --enable-apc --enable-apc-mmap --with-php-config=/opt/phpfcgi-4.4.9/bin/php-config \
    && make \
    && make install

RUN mkdir /app

WORKDIR /app

ENTRYPOINT [ "/opt/phpfcgi-4.4.9/bin/php" ]

