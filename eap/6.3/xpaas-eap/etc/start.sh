#!/bin/sh

DOCKER_IP=$(ip addr show eth0 | grep -E '^\s*inet' | grep -m1 global | awk '{ print $2 }' | sed 's|/.*||')

JBOSS_COMMON_ARGS="-Djboss.bind.address=$DOCKER_IP -Djboss.bind.address.management=$DOCKER_IP "
JBOSS_NODE_NAME_ARGS="-Djboss.node.name=$JBOSS_EAP_NODE_NAME "
JBOSS_MANAGEMENT_PORT_ARGS="-Djboss.management.native.port=$JBOSS_EAP_MGMT_NATIVE_PORT -Djboss.management.http.port=$JBOSS_EAP_MGMT_HTTP_PORT -Djboss.management.https.port=$JBOSS_EAP_MGMT_HTTPS_PORT "
JBOSS_DEFAULT_PORT_ARGS="-Djboss.default.ajp.port=$JBOSS_EAP_AJP_PORT -Djboss.default.http.port=$JBOSS_EAP_HTTP_PORT -Djboss.default.https.port=$JBOSS_EAP_HTTPS_PORT "

if [[ -z "$JBOSS_EAP_STANDALONE_CONF_FILE " ]] ; then
    echo "No custom JBoss Application Server configuration file set. Using the default standalone-full-ha.xml"
    export $JBOSS_EAP_STANDALONE_CONF_FILE=standalone-full-ha.xml
fi
if [[ -z "$JBOSS_BIND_ADDRESS" ]] ; then
    echo "No custom JBoss Application Server bind address set. Using the current container's IP address '$DOCKER_IP'."
    export JBOSS_BIND_ADDRESS=$DOCKER_IP
fi

# *******************
# RUNNING EAP Server
# *******************
# Boot EAP in standalone mode by default
# When using CMD environment variables are not expanded,
# so we need to specify the $JBOSS_HOME path
#
echo "Starting JBoss EAP version $JBOSS_EAP_VERSION in standalone mode"
echo "Using as JBoss EAP conf file: $JBOSS_EAP_STANDALONE_CONF_FILE"
echo "Using as JBoss EAP node name: $JBOSS_EAP_NODE_NAME"
echo "Using as JBoss EAP arguments: $JBOSS_COMMON_ARGS $JBOSS_NODE_NAME_ARGS $JBOSS_DEFAULT_PORT_ARGS $JBOSS_MANAGEMENT_PORT_ARGS"
if [[ -n "$JBOSS_EAP_DEBUG_PORT" ]] ; then
    echo "Using as JBoss EAP debug port: $JBOSS_EAP_DEBUG_PORT"
    export JBOSS_DEBUG_ARGS="--debug $JBOSS_EAP_DEBUG_PORT"
fi
/opt/jboss/eap/bin/standalone.sh --server-config=$JBOSS_EAP_STANDALONE_CONF_FILE $JBOSS_NODE_NAME_ARGS $JBOSS_COMMON_ARGS $JBOSS_DEFAULT_PORT_ARGS $JBOSS_MANAGEMENT_PORT_ARGS $JBOSS_DEBUG_ARGS