#!/bin/bash
# 适用于centos6

echo '-----------------------------install mysql------------------------------'
#dedine
mysql_down_url=http://mirrors.sohu.com/mysql/MySQL-5.7/mysql-5.7.18.tar.gz
boost_down_url=http://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz
mysql_install_dir=/usr/local/mysql
mysql_src=mysql-5.7.18
data_dir=/data/mysql

echo '安装依赖包...'
yum -y install gcc gcc-c++ ncurses ncurses-devel cmake make perl  autoconf automake zlib libxml libgcrypt libtool bison
yum clean all

echo '下载源文件...'
if [ -f boost_1_59_0.tar.gz ]; then
    tar zxvf boost_1_59_0.tar.gz
    else
        wget ${boost_down_url}
        tar zxvf boost_1_59_0.tar.gz
fi
if [ -f ${mysql_src}.tar.gz ]; then
    tar zxvf ${mysql_src}.tar.gz
    else
        wget ${mysql_down_url}
        tar zxvf ${mysql_src}.tar.gz
fi

echo '创建用户组'
egrep "^mysql" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
    groupadd mysql
fi
id mysql >& /dev/null
if [ $? -ne 0 ]
then
   useradd -g mysql mysql
fi

mv boost_1_59_0 /usr/local/boost
rm -rf boost*
echo '开始安装...'
cd ${mysql_src}
[ ! -d "${mysql_install_dir}" ] && mkdir -p ${mysql_install_dir}
chown -R mysql:mysql ${mysql_install_dir}
cmake \
-DCMAKE_INSTALL_PREFIX=${mysql_install_dir} \
-DMYSQL_DATADIR=${data_dir}   \
-DWITH_BOOST=/usr/local/boost \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DENABLE_DTRACE=0 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EMBEDDED_SERVER=1 \
-DMYSQL_UNIX_ADDR=${mysql_install_dir}/mysql.sock

make -j `grep processor /proc/cpuinfo | wc -l`
make install

if [ -d "${mysql_install_dir}/support-files" ];then
    echo "MySQL install successfully!"
else
    rm -rf ${mysql_install_dir}
    echo "MySQL install failed"
    kill -9 $$
fi

cp ${mysql_install_dir}/support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
chkconfig mysql on
cd ..
rm -rf mysql*
cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = ${mysql_install_dir}/mysql.sock
default-character-set=utf8
[mysqld]
port = 3306
socket = ${mysql_install_dir}/mysql.sock
basedir = ${mysql_install_dir}
datadir  = ${data_dir}
skip-name-resolve
character_set_server=utf8
init_connect='SET NAMES utf8'
log-error=/var/log/mysql.err

EOF

#初始化 密码为空
mkdir -p ${data_dir}
${mysql_install_dir}/bin/mysqld  --user=mysql --basedir=${mysql_install_dir} --datadir=${data_dir} --initialize-insecure
chown -R mysql:mysql ${data_dir}

echo '------------------------END----------------------------------'
echo "执行`service mysqld start` 启动mysql"

