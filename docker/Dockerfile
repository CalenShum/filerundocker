FROM php:7.2-apache

# COPY ./sources.list /etc/apt/sources.list
COPY ./filerun-optimization.ini /usr/local/etc/php/conf.d/
COPY ./db.sql /filerun.setup.sql
COPY ./autoconfig.php /
COPY ./entrypoint.sh /
COPY ./wait-for-it.sh /
COPY ./import-db.sh /
COPY ./install-aria2-ui.sh /
COPY ./ioncube_loaders_lin_x86-64.tar.gz /
COPY ./filerun.zip /
COPY ./master.zip /

ENV FR_DB_HOST db
ENV FR_DB_PORT 3306
ENV FR_DB_NAME filerun
ENV FR_DB_USER filerun
ENV FR_DB_PASS filerun
ENV APACHE_RUN_USER user
ENV APACHE_RUN_USER_ID 1000
ENV APACHE_RUN_GROUP user
ENV APACHE_RUN_GROUP_ID 1000

VOLUME ["/var/www/html", "/user-files"]

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get install -y \
        libapache2-mod-xsendfile \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libxml2-dev \
        libldap2-dev \
        libcurl4-gnutls-dev \
        dcraw \
        locales \
        graphicsmagick \
        ffmpeg \
        mysql-client \
        unzip \
        cron \
        vim \
        wget \
        aria2 \
        git \
        vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install -j$(nproc) pdo_mysql exif zip gd opcache dom ldap \
    && chmod +x /wait-for-it.sh \
    && chmod +x /import-db.sh \
    && chmod +x /install-aria2-ui.sh \
    && chmod +x /entrypoint.sh \
    # && curl -o /ioncube_loaders_lin_x86-64.tar.gz -L http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar xvfz /ioncube_loaders_lin_x86-64.tar.gz \
    && PHP_EXT_DIR=$(php-config --extension-dir) \
    && cp "ioncube/ioncube_loader_lin_7.2.so" $PHP_EXT_DIR \
    && echo "zend_extension=ioncube_loader_lin_7.2.so" >> /usr/local/etc/php/conf.d/00_ioncube_loader_lin_7.2.ini \
    && rm -rf ioncube /ioncube_loaders_lin_x86-64.tar.gz \
    # && curl -o /filerun.zip -L https://filerun.com/download-latest-php72 \
    # && curl -o /master.zip -L https://github.com/mayswind/AriaNg-DailyBuild/archive/master.zip \
    && mkdir -p /user-files/superuser/dl \
    && chown -R www-data:www-data /user-files \
    && chmod 777 -R /var/www \
    && mkdir -p /var/www/html/filerun \
    && mkdir -p /var/www/html/dweb \
    && chown -R www-data:www-data /var/www/html/filerun \
    && chown -R www-data:www-data /var/www/html/dweb \
    && chmod 777 -R /user-files

# Enable Apache XSendfile
RUN { \
		echo 'XSendFile On'; \
		echo; \
		echo 'XSendFilePath /user-files'; \
	} | tee "/etc/apache2/conf-available/filerun.conf" \
	&& a2enconf filerun

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
