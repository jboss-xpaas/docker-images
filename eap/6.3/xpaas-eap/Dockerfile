############################################################
# Dockerfile to build xpaas-eap image including:
# - OpenJDK 1.7.0
# - JBoss EAP 6.3.x
# Version: 6.3
############################################################

####### BASE ############
FROM docker-registry.usersys.redhat.com/goldmann/jboss-eap:6.3

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### ENVIRONEMNT ############
# JBoss EAP configuration variables
# ENV JBOSS_BIND_ADDRESS 127.0.0.1 // Not set. By default uses the running docker container's ip address.
ENV JBOSS_EAP_STANDALONE_CONF_FILE standalone-full-ha.xml
ENV JBOSS_EAP_HTTP_PORT 8080
ENV JBOSS_EAP_HTTPS_PORT 8443
ENV JBOSS_EAP_AJP_PORT 8009
ENV JBOSS_EAP_MGMT_NATIVE_PORT 9999
ENV JBOSS_EAP_MGMT_HTTP_PORT 9990
ENV JBOSS_EAP_MGMT_HTTPS_PORT 9443
ENV JBOSS_EAP_NODE_NAME node1
# ENV JBOSS_EAP_DEBUG_PORT


####### CUSTOM JBOSS USER ############
# Switchback to jboss user
USER jboss

# There is an issue in Docker with ADD command.
# When a file is added into the container's filesystem, the file owner is always root, instead of the current running user.
# See https://github.com/docker/docker/issues/5110
# The workaround is doing a chown using root user and then switchback to jboss user.
ADD etc/start.sh /opt/jboss/eap/start.sh
ADD etc/standalone-full-ha.xml /opt/jboss/eap/standalone/configuration/standalone-full-ha.xml
ADD etc/default-users.properties /opt/jboss/eap/standalone/configuration/default-users.properties
ADD etc/default-roles.properties /opt/jboss/eap/standalone/configuration/default-roles.properties
USER root
RUN chown jboss:jboss /opt/jboss/eap/start.sh; \
chown jboss:jboss /opt/jboss/eap/standalone/configuration/standalone-full-ha.xml; \
chown jboss:jboss /opt/jboss/eap/standalone/configuration/default-users.properties; \
chown jboss:jboss /opt/jboss/eap/standalone/configuration/default-roles.properties;

# Add the executable flag.
RUN chmod +x /opt/jboss/eap/start.sh

# Switchback to jboss user
USER jboss

VOLUME /opt/jboss/eap/configuration
VOLUME /opt/jboss/eap/modules
VOLUME /opt/jboss/eap/deployments

####### RUN EAP ############
CMD ["/opt/jboss/eap/start.sh"]