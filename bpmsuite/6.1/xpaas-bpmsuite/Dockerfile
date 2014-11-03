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


####### BPMS CUSTOM CONFIGURATION ############
RUN mkdir -p /opt/jboss/bpms/index /opt/jboss/bpms/vfs
ADD etc/start-bpms.sh /opt/jboss/bpms
ADD etc/standalone-full-ha.xml /opt/jboss/eap/standalone/configuration/standalone-full-ha.xml
ADD etc/bpms-users.properties /opt/jboss/eap/standalone/configuration/bpms-users.properties
ADD etc/bpms-roles.properties /opt/jboss/eap/standalone/configuration/bpms-roles.properties

####### RUNNING BPMS ############
CMD ["/opt/jboss/bpms/start-bpms.sh"]