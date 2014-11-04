XPaaS JBoss BRMS Docker image
===================================

This project builds a [docker](http://docker.io/) container for running JBoss BRMS.

This image provides a container including:
* OpenJDK 1.7.0
* JBoss EAP 6.3.1
* JBoss BRMS 6.1.0.DR4-redhat3

Table of contents
------------------

* **[Control scripts](#control-scripts)**
* **[Building the docker container](#building-the-docker-container)**
* **[Running the container](#running-the-container)**
* **[Using JBoss BRMS](#using-jboss-brms)**
* **[BRMS Users and roles](#brms-users-and-roles)**
* **[Accessing the container](#accessing-the-container)**
* **[Logging](#logging)**
* **[Stopping the container](#stopping-the-container)**
* **[Experimenting](#experimenting)**
* **[Notes](#notes)**

Control scripts
---------------

There are three control scripts for running BRMS with no clustering support:
* <code>build.sh</code> Builds the XPaaS JBoss BRMS docker image
* <code>start.sh</code> Starts a new XPaaS JBoss BRMS docker container based on this image
* <code>stop.sh</code>  Stops the runned XPaaS JBoss BRMS docker container

Building the docker container
-----------------------------

Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

If you are on OS X then see [How to use Docker on OS X](DockerOnOSX.md).

First, clone the repository:

    git clone git@github.com:jboss-xpaas/docker-images.git
    cd docker-images/brpm/6.1/xpaas-brms

Build the container:

    ./build.sh

Running the container
---------------------

To run a new container:

    ./start.sh [-c <container_name>]
    Example: ./start.sh -c xpaas_brms

Or you can try it out via docker command directly:

    docker run -P -d [--name <container_name>] redhat/xpaas-brms:6.1

These commands will start JBoss BRMS web application.

**Environment variables**

You can set additional environment variables when running the container for configuring JBoss BRMS:

For running BRMS using an external database, you need to specify some database connection arguments:

- <code>BRMS_CONNECTION_URL</code> - The database connection URL. If not set, defaults to <code>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</code>
- <code>BRMS_CONNECTION_DRIVER</code> - The database connection driver. See [Notes] for available database connection drivers. If not set, defaults to <code>h2</code>
- <code>BRMS_CONNECTION_USER</code> - The database connection username. If not set, defaults to <code>sa</code>
- <code>BRMS_CONNECTION_PASSWORD</code> - The database connection password. If not set, defaults to <code>sa</code>

For running BRMS in a clustered environment, you need to specify some other parameters:

- <code>BRMS_ZOOKEEPER_SERVER</code> - The Apache Zookeeper server URL in a format as <ocde>&lt;server:port&gt;</code>, not set by default
- <code>BRMS_CLUSTER_NAME</code> - The Apache helix cluster name to use, not set by default
- <code>BRMS_CLUSTER_NODE</code> - The number of the current node that will compose the cluster, defaults to <code>1</code>
- <code>BRMS_VFS_LOCK</code> -  The Apache helix VFS repository lock name to use, defaults to <code>brms-vfs-lock</code>
- <code>BRMS_GIT_HOST</code> - The Git daemon host, defaults to the current container's IP address
- <code>BRMS_GIT_DIR</code> - The Git daemon working directory, defaults to <code>/opt/jboss/brms/vfs</code>
- <code>BRMS_GIT_PORT</code> - The Git daemon port, defaults to <code>9520</code>
- <code>BRMS_SSH_PORT</code> - The SSH daemon port, defaults to <code>9521</code>
- <code>BRMS_SSH_HOST</code> - The SSH daemon host, defaults to the current container's IP address
- <code>BRMS_INDEX_DIR</code> - The Lucene index directory, defaults to <code>/opt/jboss/brms/index</code>

Using JBoss BRMS
----------------
By default, the JBoss EAP HTTP interface bind address points to the docker container's IP address.
The docker container's IP address that can be found by running:

    docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container_id>

Then you can type this URL:

    http://<container_ip_address>:8080/business-central

**Notes**
* The context name for JBoss BRMS is <code>business-central</code>
* See **[BRMS Users and roles](#brms-users-and-roles)** in order to see default users & passwords.

BRMS Users and roles
--------------------

BRMS uses a custom security application realm based on a properties file.

The default JBoss BRMS application users & roles are:

<table>
    <tr>
        <td><b>User</b></td>
        <td><b>Password</b></td>
        <td><b>Role</b></td>
    </tr>
    <tr>
        <td>admin</td>
        <td>admin</td>
        <td>admin</td>
    </tr>
    <tr>
        <td>analyst</td>
        <td>analyst</td>
        <td>analyst</td>
    </tr>
    <tr>
        <td>developer</td>
        <td>developer</td>
        <td>developer</td>
    </tr>
    <tr>
        <td>manager</td>
        <td>manager</td>
        <td>manager</td>
    </tr>
    <tr>
        <td>user</td>
        <td>user</td>
        <td>user</td>
    </tr>
</table>

You can manage additional users and roles by editing the following properties files:

    vi /opt/jboss/eap/standalone/configuration/brms-users.properties
    vi /opt/jboss/eap/standalone/configuration/brms-roles.properties

Accessing the container
-----------------------

You can access the container using <code>nsenter</code>.

To access your latest running container type:

    sudo nsenter -t $(docker inspect --format '{{ .State.Pid }}' $(docker ps -lq)) -m -u -i -n -p -w

To access a given <code>container_id</code> type:

    sudo nsenter -t $(docker inspect --format '{{ .State.Pid }}' <container_id> ) -m -u -i -n -p -w


Logging
-------

You can see all logs generated by the <code>standalone</code> binary running:

    docker logs [-f] <container_id>

You can attach the container by running:

    docker attach <container_id>


The BRMS web application logs can be found inside the container at path:

    /opt/jboss/eap/standalone/log/server.log

    Example:
    sudo nsenter -t $(docker inspect --format '{{ .State.Pid }}' $(docker ps -lq)) -m -u -i -n -p -w
    -bash-4.2# tail -f /opt/jboss/eap/standalone/log/server.log


Stopping the container
----------------------

To stop the previous container run using <code>start.sh</code> script just type:

    ./stop.sh

Experimenting
-------------
To spin up a shell in one of the containers try:

    docker run -P -i -t redhat/xpaas-brms /bin/bash

You can then noodle around the container and run stuff & look at files etc.

In order to run all container services provided by this image, you have to run the following command:

    sh /opt/jboss/brms/start-brms.sh

Notes
-----
* This container forces to start JBoss EAP using <code>full-ha</code> profile.
* Unsupported / pending / TODOS:
    - External database not supported yet.
    - Clustering not supported yet.
