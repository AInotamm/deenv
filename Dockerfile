# 调试开发环境
# author： Aexcm Irvin (石文俊)
#

FROM centos:centos7
MAINTAINER AI <rondonay@gmail.com>

# Setting Datetime Zone
RUN cp -p /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Replace mirrors port
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
COPY bash/repo/CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo

# Init YUM env
RUN yum -y update && yum clean all && yum makecache

# CentOS has epel release in the extras repo
RUN	yum -y install epel-release

# For OLD "service"
RUN yum -y install initscripts

# Fix Issues: https://github.com/docker/docker/issues/7459#trinitronx
ENV container=docker

# Fix SystemD: https://forums.docker.com/t/any-simple-and-safe-way-to-start-services-on-centos7-systemd/5695/7
RUN yum -y install systemd && yum clean all
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install base tool
RUN yum -y install vim wget tar

# Install develop tool
RUN yum -y groupinstall development

# Install IUS Repo
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
	rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# Install SSH Service AND init password
RUN yum -y install openssh-server passwd
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
	echo "qwertyuiop" | passwd "root" --stdin

# Install crontab service
RUN yum -y install vixie-cron crontabs

# Install Git need package
RUN yum -y install curl-devel expat-devel gettext-devel devel zlib-devel perl-devel

# Install php-fpm
RUN yum -y --enablerepo=webtatic install php56w php56w-fpm php56w-mbstring php56w-fpm php56w-mbstring php56w-xml php56w-mysql php56w-pdo php56w-mcrypt php56w-gd php56w-pecl-imagick php56w-opcache php56w-pecl-memcache php56w-pecl-xdebug

# Install nginx
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
	rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
	yum -y update nginx-release-centos && \
	cp -p /etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo.backup && \
	sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/nginx.repo
RUN yum -y --enablerepo=nginx install nginx

# Setting composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Install laravel-envoy
RUN composer global require "laravel/envoy=~1.0"

# Install supervisor
RUN yum -y install python-setuptools && \
	easy_install supervisor && \
	echo_supervisord_conf > /etc/supervisord.conf

# Install Git
RUN cd ~/ && \
	wget -c https://www.kernel.org/pub/software/scm/git/git-2.8.2.tar.gz && \
	tar zxf ./git-2.8.2.tar.gz && \
	cd ./git-2.8.2 && \
	./configure && make && make install && \
	rm -rf ~/git-2.8.2*

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Run SSHD Service
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_ed25519_key

# Copy configuration file
ADD . /opt/

# Create Base ENV
RUN chmod 755 /opt/bash/init.sh && \
	echo "/opt/bash/init.sh" >> /root/.bashrc && \
	echo 'export PATH="/root/.composer/vendor/bin:$PATH"' >> /root/.bashrc

# Setting lnmp
RUN chmod 755 /opt/bash/lnmp.sh && \
	bash /opt/bash/lnmp.sh

# Setup default path
WORKDIR /home

# Expose PORT
EXPOSE 22 80

# Data Volume for web
VOLUME ["/sys/fs/cgroup", "/home/website", "/home/config", "/home/logs"]

# Start run shell
CMD ["supervisord", "-n"]

