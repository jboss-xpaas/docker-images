#!/bin/sh

DOCKER_IP=$(ip addr show eth0 | grep -E '^\s*inet' | grep -m1 global | awk '{ print $2 }' | sed 's|/.*||')

JBOSS_COMMON_ARGS="-Djboss.bind.address=$DOCKER_IP -Djboss.bind.address.management=$DOCKER_IP "
JBOSS_BPMS_DB_ARGUMENTS=
JBOSS_BPMS_CLUSTER_ARGUMENTS=

# JBoss EAP configuration.
if [[ -z "$JBOSS_BIND_ADDRESS" ]] ; then
    echo "Not custom JBoss Application Server bind address set. Using the current container's IP address '$DOCKER_IP'."
    export JBOSS_BIND_ADDRESS=$DOCKER_IP
fi

# BPMS database configuration
JBOSS_BPMS_DB_ARGUMENTS=" -Djboss.bpms.connection_url=\"$BPMS_CONNECTION_URL\" -Djboss.bpms.driver=\"$BPMS_CONNECTION_DRIVER\" "
JBOSS_BPMS_DB_ARGUMENTS="$JBOSS_BPMS_DB_ARGUMENTS -Djboss.bpms.username=\"$BPMS_CONNECTION_USER\" -Djboss.bpms.password=\"$BPMS_CONNECTION_PASSWORD\" "

# *************************************************
# Webapp persistence descriptor dynamic generation.
# *************************************************
PERSISTENCE_TEMPLATE_PATH=/opt/jboss/eap/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml.template
PERSISTENCE_PATH=/opt/jboss/eap/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml
DEFAULT_DIALECT=org.hibernate.dialect.H2Dialect
DIALECT=org.hibernate.dialect.H2Dialect
# Remove, if existing, the current webapp persistence descriptor.
if [ -f $PERSISTENCE_PATH ]; then
    rm -f $PERSISTENCE_PATH
fi
# Check H2 database.
if [[ $BPMS_CONNECTION_DRIVER == *h2* ]]; 
then
    echo "Using H2 dialect for BPMS webapp"
    DIALECT=org.hibernate.dialect.H2Dialect
fi

# Check MySQL database.
if [[ $BPMS_CONNECTION_DRIVER == *mysql* ]]; 
then
    echo "Using MySQL dialect for BPMS webapp"
    DIALECT=org.hibernate.dialect.MySQLDialect
fi
# Generate the webapp persistence descriptor using the dialect specified.
sed -e "s;$DEFAULT_DIALECT;$DIALECT;" $PERSISTENCE_TEMPLATE_PATH > $PERSISTENCE_PATH

# *********************************************
# EAP standalone descriptor dynamic generation.
# *********************************************
JBOSS_CLUSTER_PROPERTIES_START="<!--"
JBOSS_CLUSTER_PROPERTIES_END="-->"
if [[ ! -z "$BPMS_CLUSTER_NAME" ]] ; then
    echo "Enabling cluster support for BPMS webapp"
    JBOSS_CLUSTER_PROPERTIES_START=""
    JBOSS_CLUSTER_PROPERTIES_END=""
fi
STANDALONE_TEMPLATE_PATH=/opt/jboss/eap/standalone/configuration/standalone-full-ha.xml.template
STANDALONE_PATH=/opt/jboss/eap/standalone/configuration/standalone-full-ha.xml
# Remove, if existing, the current standalone descriptor.
if [ -f $STANDALONE_PATH ]; then
    rm -f $STANDALONE_PATH
fi
# Generate the standalone descriptor.
sed -e "s;%CLUSTER_PROPERTIES_START%;$JBOSS_CLUSTER_PROPERTIES_START;" -e "s;%CLUSTER_PROPERTIES_END%;$JBOSS_CLUSTER_PROPERTIES_END;" $STANDALONE_TEMPLATE_PATH > $STANDALONE_PATH

# ***************************
# BPMS cluster configuration
# ***************************
if [[ ! -z "$BPMS_CLUSTER_NAME" ]] ; then
    
    if [[ -z "$BPMS_GIT_HOST" ]] ; then
        echo "Assigning GIT host adress using current container's ip address '$DOCKER_IP'"
        export BPMS_GIT_HOST=$DOCKER_IP
    fi
    
    if [[ -z "$BPMS_SSH_HOST" ]] ; then
        echo "Assigning SSH host adress using current container's ip address '$DOCKER_IP'"
        export BPMS_SSH_HOST=$DOCKER_IP                
    fi
    
    JBOSS_BPMS_CLUSTER_ARGUMENTS=" -Djboss.bpms.git.host=$BPMS_GIT_HOST -Djboss.bpms.git.port=$BPMS_GIT_PORT -Djboss.bpms.git.dir=$BPMS_GIT_DIR -Djboss.bpms.ssh.host=$BPMS_SSH_HOST -Djboss.bpms.ssh.port=$BPMS_SSH_PORT "
    JBOSS_BPMS_CLUSTER_ARGUMENTS=" $JBOSS_BPMS_CLUSTER_ARGUMENTS -Djboss.bpms.index.dir=$BPMS_INDEX_DIR -Djboss.bpms.cluster.id=$BPMS_CLUSTER_NAME -Djboss.bpms.cluster.zk=$BPMS_ZOOKEEPER_SERVER -Djboss.bpms.cluster.node=$JBOSS_NODE_NAME"
    JBOSS_BPMS_CLUSTER_ARGUMENTS=" $JBOSS_BPMS_CLUSTER_ARGUMENTS -Djboss.bpms.vfs.lock=$BPMS_VFS_LOCK -Djboss.bpms.quartz.properties=$BPMS_QUARTZ_PROPERTIES -Djboss.messaging.cluster.password=$BPMS_CLUSTER_PASSWORD "

    echo "Configuring HELIX client for BPMS server instance '$JBOSS_NODE_NAME' into cluster '$BPMS_CLUSTER_NAME'"
    
    # Register the node.
    echo "Registering cluster node #$BPMS_CLUSTER_NODE named '$JBOSS_NODE_NAME' into '$BPMS_CLUSTER_NAME'"
    $HELIX_HOME/bin/helix-admin.sh --zkSvr $BPMS_ZOOKEEPER_SERVER --addNode $BPMS_CLUSTER_NAME $JBOSS_NODE_NAME
    
    # Rebalance the cluster resource.
    echo "Rebalacing clustered resource '$BPMS_VFS_LOCK' in cluster '$BPMS_CLUSTER_NAME' using $BPMS_CLUSTER_NODE replicas"
    $HELIX_HOME/bin/helix-admin.sh --zkSvr $BPMS_ZOOKEEPER_SERVER --rebalance $BPMS_CLUSTER_NAME $BPMS_VFS_LOCK $BPMS_CLUSTER_NODE
    
fi

# *******************
# RUNNING BPMS Server
# *******************
# Boot EAP with BPMS in standalone mode by default
# When using CMD environment variables are not expanded,
# so we need to specify the $JBOSS_HOME path
#
# The standalone-secure.sh script is used because it's
# recommended by the installation guide.
#
# TODO: Currently BPMS cannot boot using standalone-secure.sh
# As a workaround we use standalone.sh
echo "Starting JBoss BPMS version $JBOSS_BPMS_VERSION-$JBOSS_BPMS_VERSION_RELEASE in standalone mode"
echo "Using as JBoss EAP arguments: $JBOSS_COMMON_ARGS"
echo "Using as JBoss BPMS connection arguments: $JBOSS_BPMS_DB_ARGUMENTS"
if [[ ! -z "$BPMS_CLUSTER_NAME" ]] ; then
    echo "Using as JBoss BPMS cluster arguments: $JBOSS_BPMS_CLUSTER_ARGUMENTS"
fi
/opt/jboss/eap/bin/standalone.sh --server-config=standalone-full-ha.xml $JBOSS_COMMON_ARGS $JBOSS_BPMS_DB_ARGUMENTS $JBOSS_BPMS_CLUSTER_ARGUMENTS