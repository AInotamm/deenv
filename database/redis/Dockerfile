# 数据存储环境
# Redis-Server
#

FROM centos:centos7
MAINTAINER AI <rondonay@gmail.com>

ENV REDIS_USER=redis \
	REDIS_DATA_DIR=/var/lib/redis \
	REDIS_LOG_DIR=/var/log/redis

# Init YUM env
RUN yum -y update && yum clean all

# Add epel Source
RUN yum -y install epel-release

# Install Redis
RUN yum -y install redis && \
	sed 's/^daemonize yes/daemonize no/' -i /etc/redis.conf && \
	sed 's/^bind 127.0.0.1/bind 0.0.0.0/' -i /etc/redis.conf && \
	sed 's/^# unixsocket /unixsocket /' -i /etc/redis.conf && \
	sed 's/^# unixsocketperm 755/unixsocketperm 777/' -i /etc/redis.conf && \
	sed '/^logfile/d' -i /etc/redis.conf

COPY bash/docker-entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

# User REDIS Logging
USER redis

EXPOSE 6379

VOLUME ["${REDIS_DATA_DIR}"]

ENTRYPOINT ["/entrypoint.sh"]
