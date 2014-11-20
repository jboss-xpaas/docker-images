#!/bin/sh

DOCKER_IP=$(ip addr show eth0 | grep -E '^\s*inet' | grep -m1 global | awk '{ print $2 }' | sed 's|/.*||')

JBOSS_COMMON_ARGS="-Djboss.bind.address=$DOCKER_IP -Djboss.bind.address.management=$DOCKER_IP "
JBOSS_BRMS_DB_ARGUMENTS=
JBOSS_BRMS_CLUSTER_ARGUMENTS=

# JBoss EAP configuration.
if [[ -z "$JBOSS_BIND_ADDRESS" ]] ; then
    echo "Not custom JBoss Application Server bind address set. Using the current container's IP address '$DOCKER_IP'."
    export JBOSS_BIND_ADDRESS=$DOCKER_IP
fi

# BRMS database configuration
JBOSS_BRMS_DB_ARGUMENTS=" -Djboss.brms.connection_url=\"$BRMS_CONNECTION_URL\" -Djboss.brms.driver=\"$BRMS_CONNECTION_DRIVER\" "
JBOSS_BRMS_DB_ARGUMENTS="$JBOSS_BRMS_DB_ARGUMENTS -Djboss.brms.username=\"$BRMS_CONNECTION_USER\" -Djboss.brms.password=\"$BRMS_CONNECTION_PASSWORD\" "

# BRMS cluster configuration
if [[ ! -z "$BRMS_CLUSTER_NAME" ]] ; then
    
    if [[ -z "$BRMS_GIT_HOST" ]] ; then
        echo "Assigning GIT host adress using current container's ip address '$DOCKER_IP'"
        export BRMS_GIT_HOST=$DOCKER_IP
    fi
    
    if [[ -z "$BRMS_SSH_HOST" ]] ; then
        echo "Assigning SSH host adress using current container's ip address '$DOCKER_IP'"
        export BRMS_SSH_HOST=$DOCKER_IP
    fi
    
    JBOSS_BRMS_CLUSTER_ARGUMENTS=" -Djboss.brms.git.host=$BRMS_GIT_HOST -Djboss.brms.git.port=$BRMS_GIT_PORT -Djboss.brms.git.dir=$BRMS_GIT_DIR -Djboss.brms.ssh.host=$BRMS_SSH_HOST -Djboss.brms.ssh.port=$BRMS_SSH_PORT "
    JBOSS_BRMS_CLUSTER_ARGUMENTS=" $JBOSS_BRMS_CLUSTER_ARGUMENTS -Djboss.brms.index.dir=$BRMS_INDEX_DIR -Djboss.brms.cluster.id=$BRMS_CLUSTER_NAME -Djboss.brms.cluster.zk=$BRMS_ZOOKEEPER_SERVER -Djboss.brms.cluster.node=$JBOSS_NODE_NAME"
    JBOSS_BRMS_CLUSTER_ARGUMENTS=" $JBOSS_BRMS_CLUSTER_ARGUMENTS -Djboss.brms.vfs.lock=$BRMS_VFS_LOCK -Djboss.brms.quartz.properties=$BRMS_QUARTZ_PROPERTIES -Djboss.messaging.cluster.password=$BRMS_CLUSTER_PASSWORD "

    # TODO: HELIX CLIENT RELATED
    # echo "Configuring HELIX client for BRMS server instance '$JBOSS_NODE_NAME' into cluster '$BRMS_CLUSTER_NAME'"
    
    # Register the node.
    # echo "Registering cluster node #$BRMS_CLUSTER_NODE named '$JBOSS_NODE_NAME' into '$BRMS_CLUSTER_NAME'"
    # $HELIX_HOME/bin/helix-admin.sh --zkSvr $BRMS_ZOOKEEPER_SERVER --addNode $BRMS_CLUSTER_NAME $JBOSS_NODE_NAME
    
    # Rebalance the cluster resource.
    # echo "Rebalacing clustered resource '$BRMS_VFS_LOCK' in cluster '$BRMS_CLUSTER_NAME' using $BRMS_CLUSTER_NODE replicas"
    # $HELIX_HOME/bin/helix-admin.sh --zkSvr $BRMS_ZOOKEEPER_SERVER --rebalance $BRMS_CLUSTER_NAME $BRMS_VFS_LOCK $BRMS_CLUSTER_NODE
    
fi

# Boot EAP with BRMS in standalone mode by default
# When using CMD environment variables are not expanded,
# so we need to specify the $JBOSS_HOME path
#
# The standalone-secure.sh script is used because it's
# recommended by the installation guide.
#
# TODO: Currently BRMS cannot boot using standalone-secure.sh
# As a workaround we use standalone.sh
echo "Starting JBoss BRMS version $JBOSS_BRMS_VERSION-$JBOSS_BRMS_VERSION_RELEASE in standalone mode"
echo "Using as JBoss EAP arguments: $JBOSS_COMMON_ARGS"
echo "Using as JBoss BRMS connection arguments: $JBOSS_BRMS_DB_ARGUMENTS"
if [[ ! -z "$BRMS_CLUSTER_NAME" ]] ; then
    echo "Using as JBoss BRMS cluster arguments: $JBOSS_BRMS_CLUSTER_ARGUMENTS"
fi
/opt/jboss/eap/bin/standalone.sh --server-config=standalone-full-ha.xml $JBOSS_COMMON_ARGS $JBOSS_BRMS_DB_ARGUMENTS $JBOSS_BRMS_CLUSTER_ARGUMENTS