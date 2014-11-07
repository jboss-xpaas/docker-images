XPaaS JBoss BPM Suite Docker image
===================================

This project builds a [docker](http://docker.io/) container for running JBoss BPM Suite.

This image provides a container including:     
* OpenJDK 1.7.0
* JBoss EAP 6.3.1
* JBoss BPMS 6.1.0.DR4-redhat3

Table of contents
------------------

* **[Control scripts](#control-scripts)**
* **[Building the docker container](#building-the-docker-container)**
* **[Running the container](#running-the-container)**
* **[Using JBoss BPMS](#using-jboss-bpms)**
* **[BPMS Users and roles](#bpms-users-and-roles)**
* **[Accessing the container](#accessing-the-container)**
* **[External database support](#external-database-support)**
* **[Clustering](#clustering)**
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
- <code>BPMS_CONNECTION_DRIVER</code> - The database connection driver. See **[External database support](#external-database-support)** for available database connection drivers. If not set, defaults to <code>h2</code>        
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

Accessing the container
-----------------------

You can access the container using <code>nsenter</code>.        

To access your latest running container type:      

    sudo nsenter -t $(docker inspect --format '{{ .State.Pid }}' $(docker ps -lq)) -m -u -i -n -p -w

To access a given <code>container_id</code> type:

    sudo nsenter -t $(docker inspect --format '{{ .State.Pid }}' <container_id> ) -m -u -i -n -p -w

External database support
-------------------------

By default, this container runs using a H2 embedded database.       

For running BPMS using an external database, you need to specify some database connection environment variables:       

- <code>BPMS_CONNECTION_URL</code> - The database connection URL. If not set, defaults to <code>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</code>          
- <code>BPMS_CONNECTION_DRIVER</code> - The database connection driver. See [Notes] for available database connection drivers. If not set, defaults to <code>h2</code>        
- <code>BPMS_CONNECTION_USER</code> - The database connection username. If not set, defaults to <code>sa</code>
- <code>BPMS_CONNECTION_PASSWORD</code> - The database connection password. If not set, defaults to <code>sa</code>       

Currently the following DBM systems are supported, depending on the value of <code>BPMS_CONNECTION_DRIVER</code> environment variable:       

<table>
    <tr>
        <td><b>BPMS_CONNECTION_DRIVER</b></td>
        <td><b>DBMS</b></td>
    </tr>
    <tr>
        <td>h2</td>
        <td>H2</td>
    </tr>
    <tr>
        <td>mysql</td>
        <td>MySQL 5.1.X</td>
    </tr>
</table>

You can use the <code>start.sh</code> shell script to run a container with an external database support:      

    start.sh -c xpaas_bpmsuite -d "mysql" -url "jdbc:mysql://<mysql_container_ip>:<mysql_port>/<database>" -user <db_username> -password <db_password>

Clustering
----------

**BPMS clustered environment**

JBoss BPMS web application can run in a clustered environment.    
This environment consist of:       
* An Apache Zookeeper / Helix server & controller - Handle the cluster nodes      
* An external shared database between all BPMS server instances       
* Several BPMS server instances      
* An haproxy load balancer       

**Running BPMS in a clustered environment**

You can run an external Zookeeper/Helix, haproxy and database using Docker containers or system services.      
In order to run the BPMS container using these services for a clustered environment you have to set these environment variables on container startup:     
* <code>BPMS_CLUSTER_NAME</code> - The Apache helix cluster name to use, not set by default          
* <code>BPMS_ZOOKEEPER_SERVER</code> - The Apache Zookeeper server URL in a format as <ocde>&lt;server:port&gt;</code>, not set by default          
* <code>BPMS_CLUSTER_NODE</code> - The number of the current node that will compose the cluster, defaults to <code>1</code>          
* <code>BPMS_VFS_LOCK</code> -  The Apache helix VFS repository lock name to use, defaults to <code>bpms-vfs-lock</code>           
* <code>JBOSS_NODE_NAME</code> - The name for the JBoss server node, defaults to <code>node1</code>. Each server must have an unique JBoss node name.        

And the ones for the external database to use:        
* <code>BPMS_CONNECTION_URL</code> - The database connection URL. If not set, defaults to <code>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</code>          
* <code>BPMS_CONNECTION_DRIVER</code> - The database connection driver. See [Notes] for available database connection drivers. If not set, defaults to <code>h2</code>        
* <code>BPMS_CONNECTION_USER</code> - The database connection username. If not set, defaults to <code>sa</code>       
* <code>BPMS_CONNECTION_PASSWORD</code> - The database connection password. If not set, defaults to <code>sa</code>       

NOTES:        
* Currently the clustering for BPMS only works in standalone mode for all server instances.       
* The BPMS container configure the cluster parameters if <code>BPMS_CLUSTER_NAME</code> is set.       
* Zookeeper server and external database must be configured & ready before running the bpms container.        
* The external database MUST have the quartz tables created before running the bpms container.      
* IMPORTANT: Set <code>BPMS_CLUSTER_NODE</code> environment variable using the number of the current cluster instance that will compose the cluster environment. Needed in order to rebalance the clustered resource.

**Running the pre-defined clustered environment for BPMS**

This BPMS docker container image provides a script to run a pre-defined BPMS clustered environment. It:       
* Creates and configures a XPaaS UberFire cluster controller docker container.      
* Creates and configures a MySQL 5.1 docker container.      
* Creates and configures several XPaaS JBoss BPM Suite server instances.      

This script is named [start_cluster.sh](./start_cluster.sh) and has the following input arguments:        
* <code>-name | --cluster-name</code>: The name for the cluster. If not set, defaults to <code>bpms-cluster</code>.         
* <code>-vfs | --vfs-lock</code>: The name for VFS resource lock for the cluster. If not set, defaults to <code>bpms-vfs-lock</code>.        
* <code>-n | --num-instances</code>: The number of BPMS server instances that will compose the cluster. If not set, defaults to <code>2</code>.        
* <code>-db-root-pwd</code>: The root password for the MySQL database. If not set, defaults to <code>mysql</code>.        

Here is an example of how to run the script:       
    
    # With default arguments 
    sudo ./start_cluster.sh
        
    # With arguments 
    sudo ./start_cluster.sh -name bpms-cluster -vfs bpms-vfs-lock -n 2 -db-root-pwd mysql

After running it, you can see the created containers by typing:       

    docker ps -a

**Notes**
* The HA Proxy load balancer is not provided in the clustered environment by this script, as the idea is that HA Proxy will be provided by OpenShift v3 itself.                 
* Pending JBoss EAP jgroups clustering support.         

Logging
-------

You can see all logs generated by the <code>standalone</code> binary running:

    docker logs [-f] <container_id>
    
You can attach the container by running:

    docker attach <container_id>

The BPMS web application logs can be found inside the container at path:

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

    docker run -P -i -t redhat/xpaas-bpmsuite /bin/bash

You can then noodle around the container and run stuff & look at files etc.

In order to run all container services provided by this image, you have to run the following command:

    sh /opt/jboss/bpms/start-bpms.sh

Notes
-----
* This container forces to start JBoss EAP using <code>full-ha</code> profile.                         
* This container applies dynamic configuration to <code>standalone-full-ha.xml</code> (from JBoss EAP) and <code>persistence.xml</code> (from BPMS webapp) files depending on the database to use and if the environment is a clustered one.                         