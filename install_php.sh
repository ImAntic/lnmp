#!/bin/bash
# 适用于centos6

echo '--------------------------install php--------------------------------'
#dedine
php_down_url=http://cn2.php.net/distributions/php-7.1.3.tar.gz
php_install_dir=/usr/local/php
php_src=php-7.1.3

echo '安装依赖包...'
yum  -y install epel-release
yum -y install gcc  gd-devel libjpeg-devel libpng-devel libxml2-devel bzip2-devel libcurl-devel php-mcrypt libmcrypt libmcrypt-devel  curl curl-devel openssl-devel
yum clean all


echo '下载源文件...'
wget ${php_down_url}
tar zxvf ${php_src}.tar.gz

echo '创建用户组...'
egrep "^www" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
    groupadd www
fi
id www >& /dev/null
if [ $? -ne 0 ]
then
   useradd -g www www
fi

echo '开始安装...'
cd ${php_src}
./configure \
--prefix=${php_install_dir} \
--with-config-file-path=/etc/php.ini \
--enable-fpm  \
--with-fpm-user=www \
--with-fpm-group=www   \
--with-pdo-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-libxml-dir \
--with-gd \
--with-jpeg-dir \
--with-png-dir \
--with-freetype-dir \
--with-iconv-dir \
--with-zlib-dir \
--with-mcrypt \
--enable-soap \
--enable-gd-native-ttf \
--enable-ftp \
--enable-mbstring \
--enable-exif \
--enable-ipv6 \
--with-pear \
--with-curl \
--enable-bcmath \
--enable-mbstring \
--enable-sockets  \
--with-openssl  \
--with-gettext \
--with-libxml-dir

make -j `grep processor /proc/cpuinfo | wc -l` && make install

cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
cp ${php_install_dir}/etc/php-fpm.conf.default ${php_install_dir}/etc/php-fpm.conf
cp ${php_install_dir}/etc/php-fpm.d/www.conf.default ${php_install_dir}/etc/php-fpm.d/www.conf
chmod +x /etc/init.d/php-fpm
chkconfig php-fpm on
cd ..
rm -rf php*

echo '------------------------END----------------------------------'

