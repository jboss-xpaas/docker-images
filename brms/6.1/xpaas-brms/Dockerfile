####### BASE ############
FROM docker-registry.usersys.redhat.com/goldmann/jboss-brms:6.1

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### BRMS for EAP 6.1 ############

####### ENVIRONEMNT ############
# Default values for database connection variables
ENV BRMS_CONNECTION_URL "jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
ENV BRMS_CONNECTION_DRIVER h2
ENV BRMS_CONNECTION_USER sa
ENV BRMS_CONNECTION_PASSWORD sa

# BRMS requires at least the full profile (if not in a clustered environment)
ENV JBOSS_STANDALONE_CONF_FILE standalone-full.xml

# Currently the domain mode is not supported. Force standalone mode. 
ENV JBOSS_MODE STANDALONE

# Cluster related envs
# ENV BRMS_CLUSTER_NAME // Not set by default
# ENV BRMS_ZOOKEEPER_SERVER // Not set by default
ENV BRMS_VFS_LOCK brms-vfs-lock
# ENV BRMS_GIT_HOST // Set by default to the container's ip address
ENV BRMS_GIT_PORT 9520
ENV BRMS_GIT_DIR /opt/jboss/brms/vfs
# ENV BRMS_SSH_HOST // Set by default to the container's ip address
ENV BRMS_SSH_PORT 9521
ENV BRMS_INDEX_DIR /opt/jboss/brms/index
ENV BRMS_QUARTZ_PROPERTIES /opt/jboss/brms/quartz-db.properties
ENV BRMS_CLUSTER_PASSWORD brmsclustering
ENV BRMS_CLUSTER_NODE 1
ENV HELIX_VERSION 0.6.3
ENV HELIX_HOME /opt/helix

####### HELIX ############
# RUN curl --silent --output helix.tar http://ftp.cixug.es/apache/helix/$HELIX_VERSION/binaries/helix-core-$HELIX_VERSION-pkg.tar; \
# tar -xvf helix.tar; \
# mv helix-core-$HELIX_VERSION helix; \
# mv helix/ /opt/; \
# rm helix.tar

####### CUSTOM JBOSS USER ############
# Switchback to jboss user
USER jboss

####### SCRIPTS ############
WORKDIR /
RUN mkdir -p /opt/jboss/scripts/brms /opt/jboss/brms/vfs /opt/jboss/brms/index
ADD etc/start-brms.sh /opt/jboss/brms/start-brms.sh
ADD etc/standalone-full-ha.xml /opt/jboss/eap/standalone/configuration/standalone-full-ha.xml
ADD etc/brms-users.properties /opt/jboss/eap/standalone/configuration/brms-users.properties
ADD etc/brms-roles.properties /opt/jboss/eap/standalone/configuration/brms-roles.properties

USER root
RUN chown jboss:jboss /opt/jboss/brms/start-brms.sh; \
chown jboss:jboss /opt/jboss/eap/standalone/configuration/standalone-full-ha.xml; \
chown jboss:jboss /opt/jboss/eap/standalone/configuration/brms-users.properties; \
chown jboss:jboss /opt/jboss/eap/standalone/configuration/brms-roles.properties

# Add the executable flag.
RUN chmod +x /opt/jboss/brms/start-brms.sh
# Switchback to jboss user
USER jboss

####### RUNNING BRMS ############
CMD ["/opt/jboss/brms/start-brms.sh"]
