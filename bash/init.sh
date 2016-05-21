#!/bin/bash

WEB_PATH="/home/website/default"
LOG_PATH="/home/logs"
CNF_PATH="/home/config"
SSH_PATH="/root/.ssh"

# Check Service to start
function service_start()
{
	for SERVICE in nginx php-fpm sshd
	do
		if !(ps ax | grep -v grep | grep $SERVICE > /dev/null); then
			systemctl enable $SERVICE;
		fi
	done
}

# Check Supervisor to start
function service_supervisor()
{
	if (ps ax | grep -v grep | grep /etc/supervisord.conf > /dev/null); then
		RESULT="TRUE"
	else
		supervisord -c /etc/supervisord.conf;
	fi
}

# Create DIR
mkdir -p $WEB_PATH
mkdir -p $LOG_PATH
mkdir -p $CNF_PATH
mkdir -p $SSH_PATH

# Create Volume for MYSQL
mkdir -p /var/lib/mysql

# Copy default website files
if [ "`ls -A $WEB_PATH`" = "" ]; then
	\cp -fr /opt/website/default/* $WEB_PATH
fi

# Copy default log files
if [ "`ls -A $LOG_PATH`" = "" ]; then
	\cp -fr  /opt/logs/* $LOG_PATH
fi


# Copy default config files
if [ "`ls -A $CNF_PATH`" = "" ]; then
	\cp -fr /opt/config/* $CNF_PATH
fi

# Cover default nginx config
\cp -fr ${CNF_PATH}/php-fpm/php.ini /etc/php.ini
\cp -fr ${CNF_PATH}/php-fpm/www.conf /etc/php-fpm.d/www.conf
\cp -fr ${CNF_PATH}/nginx/nginx.conf /etc/nginx/nginx.conf
\cp -fr ${CNF_PATH}/nginx/sites-include/*.conf /etc/nginx/sites-include/
\rm -fr /etc/nginx/sites-enabled/*
\cp -fr ${CNF_PATH}/nginx/sites-enabled/*.conf /etc/nginx/sites-enabled/

# Cover profile ssh key
if [ -f "${CNF_PATH}/ssh/id_rsa.pub" ]; then
  \cp -fr ${CNF_PATH}/ssh/id_rsa.pub /root/.ssh/
fi

if [ -f "${CNF_PATH}/ssh-key/id_rsa" ]; then
  \cp -fr ${CNF_PATH}/ssh/id_rsa /root/.ssh/
  chmod 400 /root/.ssh/id_rsa
fi

# Cover default supervisor config
\cp -fr ${CNF_PATH}/supervisord/supervisord.conf /etc/supervisord.conf

service_start
service_supervisor
