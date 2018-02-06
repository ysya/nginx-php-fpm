FROM centos
MAINTAINER Frank Sung <ysya33333@gmail.com>

COPY ./nginx.repo /etc/yum.repos.d/nginx.repo
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum -y update
RUN yum -y upgrade

RUN yum -y install yum-utils
RUN yum-config-manager --enable remi-php72

RUN yum -y install nginx php php-mysql php-fpm pwgen python-setuptools curl git unzip
RUN yum -y install php-curl php-gd php-intl php-pear php-imagick php-imap php-pecl-mcrypt php-memcache php-pspell php-recode php-tidy php-xmlrpc php-xsl php-opcache

RUN chmod 776 /bin/sh

# nginx settings
RUN rm -rf /etc/nginx/nginx.conf
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# nginx config
COPY ./conf/default.conf /etc/nginx/conf.d
COPY ./conf/fastcgi_params /etc/nginx

RUN mv /usr/share/nginx/html /usr/share/nginx/www
RUN chown -R nginx:nginx /usr/share/nginx/www && chown -R nginx:nginx /var/lib/php/*

# PHP
# RUN sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" /etc/php.ini
RUN sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' /etc/php.ini
RUN sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /etc/php.ini
RUN sed -i 's@^short_open_tag = Off@short_open_tag = On@' /etc/php.ini
RUN sed -i 's@^expose_php = On@expose_php = Off@' /etc/php.ini
RUN sed -i 's@^request_order.*@request_order = "CGP"@' /etc/php.ini
RUN sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /etc/php.ini
RUN sed -i 's@^post_max_size.*@post_max_size = 100M@' /etc/php.ini
RUN sed -i 's@^upload_max_filesize.*@upload_max_filesize = 100M@' /etc/php.ini
RUN sed -i 's@^max_execution_time.*@max_execution_time = 600@' etc/php.ini
RUN sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' /etc/php.ini
RUN sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php.ini

RUN mv /etc/php.d/*opcache*.ini /etc/php.d/default_opcache.ini_bac
COPY ./conf/ext-opcache.ini /etc/php.d

RUN sed -i 's@^user\s.*=\s.*@user = nginx@g' /etc/php-fpm.d/www.conf
RUN sed -i 's@^group\s.*=\s.*@group = nginx@g' /etc/php-fpm.d/www.conf
RUN sed -i 's@^;listen.owner\s.*=\s.*@listen.owner = nginx@g' /etc/php-fpm.d/www.conf
RUN sed -i 's@^;listen.group\s.*=\s.*@listen.group = nginx@g' /etc/php-fpm.d/www.conf
RUN sed -i 's@^;listen.mode\s.*=\s.*@listen.mode = 0660@g' /etc/php-fpm.d/www.conf
RUN sed -i 's@^listen\s=\s.*@listen = /dev/shm/php-cgi.sock@g' /etc/php-fpm.d/www.conf

# Supervisor
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
COPY ./conf/supervisord.conf /etc/supervisord.conf

COPY ./start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 80 443

CMD ["/bin/bash", "/start.sh"]