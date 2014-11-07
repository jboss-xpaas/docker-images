#!/bin/sh

ZK_CONFIG_FILE=$ZOOKEEPER_HOME/conf/zoo.cfg
HELIX_LOGS_FILE=/tmp/controller.log

# Welcome message
echo "Welcome to XPaaS Uberfire cluster controller"  
echo 
echo "ZK - Using data directory: $ZOOKEEPER_DATA_DIR"
echo "ZK - Using client port: $ZOOKEEPER_CLIENT_PORT"
echo "ZK - Using registering servers: $ZOOKEEPER_REGISTERED_SERVERS"
echo "ZK - Using as cluster name: $CLUSTER_NAME"

# Generating zookeeper zoo.cfg
echo "ZK - Generating configuration file..."

cat /dev/null > $ZK_CONFIG_FILE
echo "# The number of milliseconds of each tick" >> $ZK_CONFIG_FILE
echo "tickTime=2000" >> $ZK_CONFIG_FILE
echo "# The number of ticks that the initial" >> $ZK_CONFIG_FILE
echo "# synchronization phase can take" >> $ZK_CONFIG_FILE
echo "initLimit=10" >> $ZK_CONFIG_FILE
echo "# The number of ticks that can pass between" >> $ZK_CONFIG_FILE
echo "# sending a request and getting an acknowledgement" >> $ZK_CONFIG_FILE
echo "syncLimit=5" >> $ZK_CONFIG_FILE
echo "# the directory where the snapshot is stored." >> $ZK_CONFIG_FILE
echo "# do not use /tmp for storage, /tmp here is just" >> $ZK_CONFIG_FILE
echo "# example sakes." >> $ZK_CONFIG_FILE
echo "dataDir=$ZOOKEEPER_DATA_DIR" >> $ZK_CONFIG_FILE
echo "# the port at which the clients will connect" >> $ZK_CONFIG_FILE
echo "clientPort=$ZOOKEEPER_CLIENT_PORT">> $ZK_CONFIG_FILE
echo "# the maximum number of client connections." >> $ZK_CONFIG_FILE
echo "# increase this if you need to handle more clients" >> $ZK_CONFIG_FILE
echo "#maxClientCnxns=60" >> $ZK_CONFIG_FILE
echo "#" >> $ZK_CONFIG_FILE
echo "# Be sure to read the maintenance section of the" >> $ZK_CONFIG_FILE
echo "# administrator guide before turning on autopurge." >> $ZK_CONFIG_FILE
echo "#" >> $ZK_CONFIG_FILE
echo "# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance" >> $ZK_CONFIG_FILE
echo "#" >> $ZK_CONFIG_FILE
echo "# The number of snapshots to retain in dataDir" >> $ZK_CONFIG_FILE
echo "#autopurge.snapRetainCount=3" >> $ZK_CONFIG_FILE
echo "# Purge task interval in hours" >> $ZK_CONFIG_FILE
echo "# Set to "0" to disable auto purge feature" >> $ZK_CONFIG_FILE
echo "#autopurge.purgeInterval=1" >> $ZK_CONFIG_FILE
echo -e "$ZOOKEEPER_REGISTERED_SERVERS"
echo -e "$ZOOKEEPER_REGISTERED_SERVERS">> $ZK_CONFIG_FILE

echo "ZK - Configuration file generated"

# Run Zookeeper in server mode.
echo "ZK - Starting server..." 
$ZOOKEEPER_HOME/bin/zkServer.sh start
echo "ZK - Server started"

echo "Helix - Adding cluster '$CLUSTER_NAME' into server 'localhost:2181'"
$HELIX_HOME/bin/helix-admin.sh --zkSvr localhost:2181 --addCluster $CLUSTER_NAME

echo "Helix - Added resource '$VFS_REPO' for cluster '$CLUSTER_NAME' into server 'localhost:2181'" 
/opt/helix/bin/helix-admin.sh --zkSvr localhost:2181 --addResource $CLUSTER_NAME $VFS_REPO 1 LeaderStandby AUTO_REBALANCE

echo "Helix - Starting helix controller. You can find the logs at '$HELIX_LOGS_FILE'"
$HELIX_HOME/bin/run-helix-controller.sh --zkSvr localhost:2181 --cluster $CLUSTER_NAME 2>&1 >> $HELIX_LOGS_FILE

echo "XPaaS Uberfire cluster controller finished"  

exit 0