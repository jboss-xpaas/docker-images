############################################################
# Dockerfile to build xpaas-bpmsuite image including:
# - OpenJDK 1.7.0
# - JBoss EAP 6.3.1
# - JBoss BPMS 6.1.0.DR4-redhat3
# Version: 6.1
############################################################

####### BASE ############
FROM docker-registry.usersys.redhat.com/goldmann/jboss-bpms:6.1

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### ENVIRONEMNT ############
# JBoss EAP configuration variables
# ENV JBOSS_BIND_ADDRESS 127.0.0.1 // Not set. By default uses the runnig docker container's ip address.

# Default values for database connection variables
ENV BPMS_CONNECTION_URL "jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
ENV BPMS_CONNECTION_DRIVER h2
ENV BPMS_CONNECTION_USER sa
# TODO: Docker best practices - Do not use passwords here 
ENV BPMS_CONNECTION_PASSWORD sa

# Cluster related envs
# ENV BPMS_CLUSTER_NAME // Not set by default
# ENV BPMS_ZOOKEEPER_SERVER // Not set by default
ENV BPMS_VFS_LOCK bpms-vfs-lock
# ENV BPMS_GIT_HOST // Set by default to the container's ip address
ENV BPMS_GIT_PORT 9520
ENV BPMS_GIT_DIR /opt/jboss/bpms/vfs
# ENV BPMS_SSH_HOST // Set by default to the container's ip address
ENV BPMS_SSH_PORT 9521
ENV BPMS_INDEX_DIR /opt/jboss/bpms/index
ENV BPMS_QUARTZ_PROPERTIES /opt/jboss/bpms/quartz-db.properties
# TODO: Docker best practices - Do not use passwords here
ENV BPMS_CLUSTER_PASSWORD bpmsclustering
ENV BPMS_CLUSTER_NODE 1
ENV HELIX_VERSION 0.6.3
ENV HELIX_HOME /opt/jboss/helix

####### CUSTOM JBOSS USER ############
# Switchback to jboss user
USER jboss

####### HELIX ############
RUN curl --silent --output /opt/jboss/helix.tar http://ftp.cixug.es/apache/helix/$HELIX_VERSION/binaries/helix-core-$HELIX_VERSION-pkg.tar; \ 
tar -xvf helix.tar; \ 
mv helix-core-$HELIX_VERSION helix; \ 
rm helix.tar

####### EAP MYSQL MODULE ############
ADD bin/mysql_module.tar.gz /opt/jboss/eap/modules/system/layers/base

####### BPMS CUSTOM CONFIGURATION ############
# Create the BPMS directories inside /opt/jboss
RUN mkdir -p /opt/jboss/bpms/index /opt/jboss/bpms/vfs

# There is an issue in Docker with ADD command.
# When a file is added into the container's filesystem, the file owner is always root, instead of the current running user.
# See https://github.com/docker/docker/issues/5110
# The workaround is doing a chown using root user and then switchback to jboss user.
ADD etc/start-bpms.sh /opt/jboss/bpms/start-bpms.sh
ADD etc/standalone-full-ha.xml.template /opt/jboss/eap/standalone/configuration/standalone-full-ha.xml.template
ADD etc/bpms-users.properties /opt/jboss/eap/standalone/configuration/bpms-users.properties
ADD etc/bpms-roles.properties /opt/jboss/eap/standalone/configuration/bpms-roles.properties
ADD etc/persistence.xml.template /opt/jboss/eap/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml.template
ADD etc/quartz-db.properties /opt/jboss/bpms/quartz-db.properties
USER root
RUN chown jboss:jboss /opt/jboss/bpms/start-bpms.sh; \ 
chown jboss:jboss /opt/jboss/eap/standalone/configuration/standalone-full-ha.xml.template; \ 
chown jboss:jboss /opt/jboss/eap/standalone/configuration/bpms-users.properties; \ 
chown jboss:jboss /opt/jboss/eap/standalone/configuration/bpms-roles.properties; \ 
chown jboss:jboss /opt/jboss/eap/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml.template; \ 
chown jboss:jboss /opt/jboss/bpms/quartz-db.properties

# Add the executable flag.
RUN chmod +x /opt/jboss/bpms/start-bpms.sh

# Switchback to jboss user
USER jboss

####### RUNNING BPMS ############
CMD ["/opt/jboss/bpms/start-bpms.sh"]