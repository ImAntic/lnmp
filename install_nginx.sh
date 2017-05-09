#!/bin/bash
# 适用于centos6

echo '-------------------------install nginx---------------------------------'
#dedine
nginx_down_url=http://nginx.org/download/nginx-1.11.9.tar.gz
nginx_install_dir=/usr/local/nginx
nginx_src=nginx-1.11.9

echo '安装依赖包...'
yum -y install openssl openssl-devel pcre-devel gcc gcc-c++
yum clean all

echo '下载源文件...'
wget ${nginx_down_url}
tar zxvf ${nginx_src}.tar.gz

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
cd ${nginx_src}
./configure \
--user=www \
--group=www \
--prefix=${nginx_install_dir} \
--with-http_realip_module \
--with-http_sub_module \
--with-http_gzip_static_module \
--with-http_stub_status_module  \
--with-pcre  \
--with-http_ssl_module

make -j `grep processor /proc/cpuinfo | wc -l` && make install
cd ..
rm -rf nginx*
cd /usr/local/sbin
ln -s ${nginx_install_dir}/sbin/nginx

echo '------------------------END----------------------------------'
