A 3D GIS Stack setup with Docker
================================

Presentation
------------

This Docker image is a container with a full 3D GIS server stack. 

It is based on Ubuntu 14.04, Phusion baseimage and docker-pggis.

From these sources it features :
* PostgreSQL 9.4 (from PGDG packages)
* PostGIS 2.1.3 (compiled from release sources) with SFCGAL support (git master)
* PgRouting (git master)
* PostgreSQL PointCloud extension (git master)
* PDAL (git master)

This image has an additional software stack with
* MapServer suite 6.4 (Ubuntu packages) including :
- Mapcache Apache module
* TinyOWS (Oslandia master)
* 3D WebGL client (Oslandia R&D work, master)

It creates a pggis database with a *pggis* superuser (password *pggis*), with postgis, pgrouting and pointcloud extensions activated. It is therefore ready to eat data, and you can enjoy 2D vector and raster features, 3D support and functions, large point data volumes and analysis, topology support and all PostgreSQL native features.

On top of the database features, you will have the MapServer suite available, with latest developments, allowing you to serve image data, as well as 3D vectorial data, supporting OGC standards.

Last but not least, a 3D web client is included, to be able to visualize your data easily. This client is a not-yet-release R&D prototype from Oslandia.

Just get me started !
---------------------

Make sure you have docker installed. On Ubuntu 14.04, Docker is named *docker.io*, replace the name by *docker* if you use another release.

If you just want to run a container with this image, you do not need this repository as the image is available on docker.io as a Trusted Build.
Just run the container and it will download the image if you do not already have it locally.

Make sure you have no service running on the host on ports 5432 or 80, or change the host port (first number) in the line below.

```sh
sudo docker.io run --rm -p 5423:5432 -p 80:80 --name 3dgis_test oslandia/3dgis /sbin/my_init
```

Test the setup
--------------

You can test if everything works by pointing a web browser in the host to this URL, using port mapping :

    http://localhost:80/client.html

Connect to the database
-----------------------

Assuming you have the postgresql-client installed, you can use the host-mapped port to test as well. You need to use docker ps to find out what local host port the container is mapped to first:

```sh
$ psql -h localhost -p 5432 -d pggis -U pggis --password
```

If you want to use this repository to build or modify the image, continue reading.

Build and/or run the container
------------------------------

Git clone this repository to get the Dockerfile, and cd to it.

You can build the image with :

```sh
sudo docker.io build -t oslandia/3dgis .
```

Run the container with :

```sh
sudo docker.io run --rm -p 5432:5432 -p 80:80 --name 3dgis_test oslandia/3dgis /sbin/my_init
```

Using the /data/ volume
-----------------------

If you want to restore a database when running the container, see the docker-pggis documentation :

* https://github.com/vpicavet/docker-pggis

You can also mount the */data* volume, so that you can keep your cache on the host and share it between containers.

If you do so, be sure to have a *cache* folder in your host's data directory, or Apache will not start.

Sample run command with volume mapping :

```sh
$ find mydata
mydata
mydata/restore
mydata/restore/lyon.sql
mydata/cache

$ docker run --rm -p 5434:5432 -p 8080:80 --name 3dgis_test -v /mydata:/data --name 3dgis_test oslandia/3dgis /sbin/my_init
```

Support
=======

Do not hesitate to fork, send pull requests or fill issues on GitHub to enhance this image.

Contact Oslandia at infos+3dgis@oslandia.com for any question or support.


