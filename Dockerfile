# Oslandia 3D GIS stack
#
# This image includes the following tools
# - PostgreSQL 9.4
# - PostGIS 2.1.3 with raster, topology and sfcgal support
# - PgRouting
# - PDAL
# - PostgreSQL PointCloud
# - Mapserver 6.4
# - Mapserver mapcache
# - TinyOWS trunk with 3D support
# - a WeGL 3D client
#
# Version 0.2

# We start from oslandia/pggis which has all
# database components ready

FROM oslandia/pggis
MAINTAINER Vincent Picavet, vincent.picavet@oslandia.com

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


# -------------- Installation --------------

# == packages needed for compilation ==
RUN apt-get update

RUN apt-get install -y autoconf build-essential cmake docbook-mathml docbook-xsl libboost-dev libboost-filesystem-dev libboost-timer-dev libcgal-dev libcunit1-dev libgdal-dev libgeos++-dev libgeotiff-dev libgmp-dev libjson0-dev libjson-c-dev liblas-dev libmpfr-dev libopenscenegraph-dev libpq-dev libproj-dev libxml2-dev postgresql-server-dev-9.4 xsltproc git build-essential wget flex libfcgi-dev

# == install mapserver and mapcache from packages ==
RUN apt-get install -y libapache2-mod-mapcache apache2 apache2-utils cgi-mapserver 

# == Compile additional softwares ==

# Compile TinyOWS
RUN git clone https://github.com/mapserver/tinyows.git
RUN cd tinyows && autoconf && ./configure --with-shp2pgsql=/usr/lib/postgresql/9.4/bin/shp2pgsql && make && make install && cp tinyows /usr/lib/cgi-bin/tinyows
# cleanup
RUN rm -Rf tinyows 

# get compiled libraries recognized
RUN ldconfig

# == clean packages ==

# all -dev packages
RUN apt-get remove -y --purge autotools-dev libgeos-dev libgif-dev libgl1-mesa-dev libglu1-mesa-dev libgnutls-dev libgpg-error-dev libhdf4-alt-dev libhdf5-dev libicu-dev libidn11-dev libjasper-dev libjbig-dev libjpeg8-dev libjpeg-dev libjpeg-turbo8-dev libkrb5-dev libldap2-dev libltdl-dev liblzma-dev libmysqlclient-dev libnetcdf-dev libopenthreads-dev libp11-kit-dev libpng12-dev libpthread-stubs0-dev librtmp-dev libspatialite-dev libsqlite3-dev libssl-dev libstdc++-4.8-dev libtasn1-6-dev libtiff5-dev libwebp-dev libx11-dev libx11-xcb-dev libxau-dev libxcb1-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-glx0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-shape0-dev libxcb-sync-dev libxcb-xfixes0-dev libxdamage-dev libxdmcp-dev libxerces-c-dev libxext-dev libxfixes-dev libxshmfence-dev libxxf86vm-dev linux-libc-dev manpages-dev mesa-common-dev libgcrypt11-dev unixodbc-dev uuid-dev x11proto-core-dev x11proto-damage-dev x11proto-dri2-dev x11proto-fixes-dev x11proto-gl-dev x11proto-input-dev x11proto-kb-dev x11proto-xext-dev x11proto-xf86vidmode-dev xtrans-dev zlib1g-dev

# installed packages
RUN apt-get remove -y --purge autoconf build-essential cmake docbook-mathml docbook-xsl libboost-dev libboost-filesystem-dev libboost-timer-dev libcgal-dev libcunit1-dev libgdal-dev libgeos++-dev libgeotiff-dev libgmp-dev libjson0-dev libjson-c-dev liblas-dev libmpfr-dev libopenscenegraph-dev libpq-dev libproj-dev libxml2-dev postgresql-server-dev-9.4 xsltproc git build-essential wget 

# additional compilation packages
RUN apt-get remove -y --purge automake m4 make

# ---------- SETUP --------------


# Add Apache/MapServer daemon
RUN mkdir /etc/service/apache2
ADD apache2.sh /etc/service/apache2/run

# Add Apache Environment variables
RUN echo www-data > /etc/container_environment/APACHE_RUN_USER
RUN echo www-data > /etc/container_environment/APACHE_RUN_GROUP
RUN echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR

# Activate needed Apache modules 
RUN a2enmod mapcache && a2enmod cgi

# Add any Apache configuration here :
ADD apache_datawww.conf /etc/apache2/sites-available/001-datawww.conf
RUN ln -s /etc/apache2/sites-available/001-datawww.conf /etc/apache2/sites-enabled/

# Add TinyOWS configuration
ADD tinyows.xml /etc/tinyows.xml

# Configure MapCache
ADD mapcache.xml /var/www/mapcache.xml
ADD apache_mapcache.conf /etc/apache2/conf-available/mapcache.conf
RUN ln -s /etc/apache2/conf-available/mapcache.conf /etc/apache2/conf-enabled/mapcache.conf

# Expose MapServer
EXPOSE 5432 80

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/data", "/etc/mapserver", "/var/log/mapserver", "/var/lib/mapcache", "/var/log/apache"]

RUN mkdir /data/cache && chmod 777 /data/cache

# ---------- Final cleanup --------------
#
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

