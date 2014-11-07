############################################################
# Dockerfile to build xpaas-uberfire-cluster-controller image including:
# - Apache Zookeeper IO v3.4.6
# - Apache Helix v0.6.3
# This image is used as a cluster controller for both BPMS/BRMS v6.1
# Version: 6.1
############################################################

####### BASE ############
FROM docker-registry.usersys.redhat.com/goldmann/jboss-base-jdk:latest

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### ENVIRONEMNT ############
ENV ZOOKEEPER_VERSION 3.4.6
ENV ZOOKEEPER_DATA_DIR /tmp/data/zookeeper
ENV ZOOKEEPER_CLIENT_PORT 2181
ENV ZOOKEEPER_REGISTERED_SERVERS #
ENV VFS_REPO vfs-repo
ENV CLUSTER_NAME zk-cluster
ENV ZOOKEEPER_HOME /opt/jboss/zookeeper
ENV HELIX_VERSION 0.6.3
ENV HELIX_HOME /opt/jboss/helix

####### CUSTOM JBOSS USER ############
# Switchback to jboss user
USER jboss
WORKDIR /opt/jboss

####### ZOOKEEPER ############
RUN curl --silent --output /opt/jboss/zookeeper.tar.gz http://ftp.cixug.es/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz; \ 
tar zxf zookeeper.tar.gz; \ 
mv zookeeper-$ZOOKEEPER_VERSION zookeeper; \ 
rm zookeeper.tar.gz

####### HELIX ############
RUN curl --silent --output /opt/jboss/helix.tar http://ftp.cixug.es/apache/helix/$HELIX_VERSION/binaries/helix-core-$HELIX_VERSION-pkg.tar; \ 
tar -xvf helix.tar; \ 
mv helix-core-$HELIX_VERSION helix; \ 
rm helix.tar

####### HELPER SCRIPTS ###########
RUN mkdir -p /opt/jboss/scripts/zookeeper
ADD etc/startup.sh /opt/jboss/scripts/zookeeper/startup.sh
# There is an issue in Docker with ADD command.
# When a file is added into the container's filesystem, the file owner is always root, instead of the current running user.
# See https://github.com/docker/docker/issues/5110
# The workaround is doing a chown using root user and then switchback to jboss user.
USER root
RUN chown jboss:jboss /opt/jboss/scripts/zookeeper/startup.sh
# Add the executable flag.
RUN chmod +x /opt/jboss/scripts/zookeeper/startup.sh

####### PORT EXPOSING ###########
EXPOSE 2181
EXPOSE 2888
EXPOSE 3888

####### DEFAULT RUN COMMAND###########
CMD ["/opt/jboss/scripts/zookeeper/startup.sh"]
