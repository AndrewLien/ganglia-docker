FROM debian:jessie

MAINTAINER kiwenlau <kiwenlau@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y

# Install Apache
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2

# Install php
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y php5 libapache2-mod-php5 php5-mcrypt php5-mysql

# Install mod_wsgi
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libapache2-mod-wsgi

# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite
RUN a2enmod headers

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Install gmetad and ganglia-web
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gmetad rrdcached rrdtool ganglia-webfrontend ganglia-monitor


# Enable ganglia-webui
RUN ln -s /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/002-ganglia.conf

# Make ganglia and rrdcached talk
RUN sed -i '/#OPTS=""/c\OPTS=" -t 60 -w 300 -z 300 -F -s ganglia -m 664 -l 127.0.0.1:9998 -s ganglia -m 777 -P FLUSH,STATS,HELP -l unix:/tmp/rrdcached.limited.sock -b /var/lib/ganglia/rrds -B -p /var/lib/ganglia/rrdcached.pid"' /etc/default/rrdcached

# Adjust permissions
RUN touch /var/lib/ganglia-web/conf/events.json
RUN chown ganglia:ganglia /var/lib/ganglia-web/conf/events.json

#ADD gmetad.conf /etc/ganglia/gmetad.conf 

RUN apt-get install -y supervisor

ADD ganglia-master.conf /etc/supervisor/conf.d/ganglia-master.conf
ADD ganglia-slave.conf /etc/supervisor/conf.d/ganglia-slave.conf

ADD gmetad.conf /etc/ganglia/gmetad.conf 
ADD gmond.conf /etc/ganglia/gmond.conf 

RUN chown -R ganglia:ganglia /etc/ganglia

RUN rm -rf /var/lib/ganglia && \
    mkdir -p /var/lib/ganglia/rrds && \
    chown -R 999:999 /var/lib/ganglia

EXPOSE 80

#CMD /etc/init.d/rrdcached start & /etc/init.d/gmetad start & /usr/sbin/apache2ctl -D FOREGROUND
