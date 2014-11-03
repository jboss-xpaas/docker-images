XPaaS JBoss BPM Suite Docker image
===================================

This project builds a [docker](http://docker.io/) container for running JBoss BPM Suite.

This image provides a container including:     
* JBoss BPMS 6.1.0.DR4-redhat3

Table of contents
------------------

* **[Control scripts](#control-scripts)**
* **[Building the docker container](#building-the-docker-container)**
* **[Running the container](#running-the-container)**
* **[Using JBoss BPMS](#using-jboss-bpms)**
* **[BPMS Users and roles](#bpms-users-and-roles)**
* **[Logging](#logging)**
* **[Stopping the container](#stopping-the-container)**
* **[Experimenting](#experimenting)**
* **[Notes](#notes)**

Control scripts
---------------

There are three control scripts for running BPMS with no clustering support:    
* <code>build.sh</code> Builds the XPaaS JBoss BPMS docker image    
* <code>start.sh</code> Starts a new XPaaS JBoss BPMS docker container based on this image    
* <code>stop.sh</code>  Stops the runned XPaaS JBoss BPMS docker container    

Building the docker container
-----------------------------

Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

If you are on OS X then see [How to use Docker on OS X](DockerOnOSX.md).

First, clone the repository:      
    
    git clone git@github.com:jboss-xpaas/docker-images.git
    cd docker-images/bpmsuite/6.1/xpaas-bpmsuite

Build the container:       

    ./build.sh

Running the container
---------------------

To run a new container:
    
    ./start.sh [-c <container_name>]
    Example: ./start.sh -c xpaas_bpmsuite

Or you can try it out via docker command directly:

    docker run -P -d [--name <container_name>] redhat/xpaas-bpmsuite:6.1

These commands will start JBoss BPM Suite web application.

**Environment variables**         

You can set additional environment variables when running the container for configuring JBoss BPM Suite:       

For running BPMS using an external database, you need to specify some database connection arguments:       

- <code>BPMS_CONNECTION_URL</code> - The database connection URL. If not set, defaults to <code>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</code>          
- <code>BPMS_CONNECTION_DRIVER</code> - The database connection driver. See [Notes] for available database connection drivers. If not set, defaults to <code>h2</code>        
- <code>BPMS_CONNECTION_USER</code> - The database connection username. If not set, defaults to <code>sa</code>
- <code>BPMS_CONNECTION_PASSWORD</code> - The database connection password. If not set, defaults to <code>sa</code>       

For running BPMS in a clustered environment, you need to specify some other parameters:     

- <code>BPMS_ZOOKEEPER_SERVER</code> - The Apache Zookeeper server URL in a format as <ocde>&lt;server:port&gt;</code>, not set by default          
- <code>BPMS_CLUSTER_NAME</code> - The Apache helix cluster name to use, not set by default          
- <code>BPMS_CLUSTER_NODE</code> - The number of the current node that will compose the cluster, defaults to <code>1</code>          
- <code>BPMS_VFS_LOCK</code> -  The Apache helix VFS repository lock name to use, defaults to <code>bpms-vfs-lock</code>           
- <code>BPMS_GIT_HOST</code> - The Git daemon host, defaults to the current container's IP address       
- <code>BPMS_GIT_DIR</code> - The Git daemon working directory, defaults to <code>/opt/jboss/bpms/vfs</code>       
- <code>BPMS_GIT_PORT</code> - The Git daemon port, defaults to <code>9520</code>          
- <code>BPMS_SSH_PORT</code> - The SSH daemon port, defaults to <code>9521</code>          
- <code>BPMS_SSH_HOST</code> - The SSH daemon host, defaults to the current container's IP address          
- <code>BPMS_INDEX_DIR</code> - The Lucene index directory, defaults to <code>/opt/jboss/bpms/index</code>          

Using JBoss BPMS
----------------
By default, the JBoss EAP HTTP interface bind address points to the docker container's IP address.           
The docker container's IP address that can be found by running:               

    docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container_id>
 
Then you can type this URL:

    http://<container_ip_address>:8080/business-central

**Notes**           
* The context name for JBoss BPMS is <code>business-central</code>      
* See **[BPMS Users and roles](#bpms-users-and-roles)** in order to see default users & passwords.              

BPMS Users and roles
--------------------

BPMS uses a custom security application realm based on a properties file.   

The default JBoss BPMS application users & roles are:

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

    vi /opt/jboss/eap/standalone/configuration/bpms-users.properties
    vi /opt/jboss/eap/standalone/configuration/bpms-roles.properties


Logging
-------

You can see all logs generated by running:

    docker logs [-f] <container_id>
    
You can attach the container by running:

    docker attach <container_id>

Stopping the container
----------------------

To stop the previous container run using <code>start.sh</code> script just type:

    ./stop.sh

Experimenting
-------------
To spin up a shell in one of the containers try:

    docker run -P -i -t redhat/xpaas-bpmsuite /bin/bash

You can then noodle around the container and run stuff & look at files etc.

In order to run all container services provided by this image, you have to run the following command:

    sh /opt/jboss/bpms/start-bpms.sh

Notes
-----
* This container forces to start JBoss EAP using <code>full-ha</code> profile.             
* Unsupported / pending / TODOS:           
    - External database not supported yet.          
    - Clustering not supported yet.            