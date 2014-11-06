############################################################
# Dockerfile to build xpaas-uberfire-cluster-controller image including:
# - Zookeeper IO v3.4.6
# - Helix v0.6.3
# This image is used as a cluster controller for both BPMS/BRMS v6.1
# Version: 6.1
############################################################

####### BASE ############
FROM docker-registry.usersys.redhat.com/goldmann/jboss-base-jdk:latest

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### ENVIRONEMNT ############
ENV ZOOKEEPER_VERSION 3.4.6
ENV ZOOKEEPER_NAME jboss
ENV ZOOKEEPER_PROFILES docker
ENV ZOOKEEPER_DATA_DIR /tmp/data/zookeeper
ENV ZOOKEEPER_CLIENT_PORT 2181
ENV ZOOKEEPER_REGISTERED_SERVERS #
ENV CLUSTER_NAME zk-cluster
ENV ZOOKEEPER_HOME /opt/zookeeper
ENV HELIX_VERSION 0.6.3
ENV HELIX_HOME /opt/helix

####### CUSTOM JBOSS USER ############
# Switchback to jboss user
USER jboss

####### ZOOKEEPER ############
WORKDIR /tmp
RUN curl --silent --output zookeeper.tar.gz http://ftp.cixug.es/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz; \ 
tar zxf zookeeper.tar.gz; \ 
mv zookeeper-$ZOOKEEPER_VERSION zookeeper; \ 
mv zookeeper/ /opt/; \ 
rm zookeeper.tar.gz

####### HELIX ############
RUN curl --silent --output helix.tar http://ftp.cixug.es/apache/helix/$HELIX_VERSION/binaries/helix-core-$HELIX_VERSION-pkg.tar; \ 
tar -xvf helix.tar; \ 
mv helix-core-$HELIX_VERSION helix; \ 
mv helix/ /opt/; \ 
rm helix.tar

####### ZOOKEEPER CONFIGURATION ############
WORKDIR /opt/zookeeper/etc

RUN echo bind.address=0.0.0.0 >> system.properties
RUN echo zookeeper.environment=docker >> system.properties
RUN echo zookeeper.password.encode=true >> system.properties

# Add a user
# TODO: should ideally come from env vars?
# TODO: Apply docker best practices and do not add passwords here
RUN touch users.properties; \  
echo admin=admin,admin >> users.properties 

# Enable logging to standard out
RUN echo log4j.rootLogger=INFO, stdout, osgi:* >> org.ops4j.pax.logging.cfg 

####### HELPER SCRIPTS ###########
WORKDIR /
RUN mkdir -p /jboss/scripts/zookeeper
ADD etc/startup.sh /jboss/scripts/zookeeper/startup.sh
# There is an issue in Docker with ADD command.
# When a file is added into the container's filesystem, the file owner is always root, instead of the current running user.
# See https://github.com/docker/docker/issues/5110
# The workaround is doing a chown using root user and then switchback to jboss user.
USER root
RUN chown jboss:jboss /jboss/scripts/zookeeper/startup.sh
# Add the executable flag.
RUN chmod +x /jboss/scripts/zookeeper/startup.sh

####### PORT EXPOSING ###########
EXPOSE 2181
EXPOSE 2888
EXPOSE 3888

####### DEFAULT RUN COMMAND###########
CMD ["/jboss/scripts/zookeeper/startup.sh"]
