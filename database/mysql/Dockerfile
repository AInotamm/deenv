# 数据存储环境
# MYSQL Server
#

FROM centos:centos7
MAINTAINER AI <rondonay@gmail.com>

# MYSQL PACKAGE PATH
ENV PACKAGE_URL https://repo.mysql.com/yum/mysql-5.7-community/docker/x86_64/mysql-community-server-minimal-5.7.12-1.el7.x86_64.rpm

# Install server
RUN rpmkeys --import http://repo.mysql.com/RPM-GPG-KEY-mysql && \
	yum -y install $PACKAGE_URL && \
	yum -y install libpwquality && \
	rm -rf /var/cache/yum/*
RUN mkdir /docker-entrypoint-initdb.d

# Set ROOT password
ENV MYSQL_ROOT_PASSWORD rEVCMFhs4deve6Rr

# Init 
COPY bash/docker-entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Mount workdir
VOLUME ["/var/lib/mysql"]

# User MYSQL Logging
USER mysql

EXPOSE 3306
CMD ["mysqld", "--console"]
