#!/bin/sh

# *******************************
# BPMS docker image start script
# *******************************

# Program arguments
#
# -c | --container-name:    The name for the created container.
#                           If not specified, defaults to "xpaas-bpmsuite"
# -h | --help;              Show the script usage
#

CONTAINER_NAME="xpaas-bpmsuite"
IMAGE_NAME="redhat/xpaas-bpmsuite"
IMAGE_TAG="6.1"

function usage
{
     echo "usage: start.sh [ [-c <container_name> ] ] [-h]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -c | --container-name ) shift
                                CONTAINER_NAME=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Check if container is already started
if [ -f docker.pid ]; then
    echo "Container is already started"
    container_id=$(cat docker.pid)
    echo "Stoping container $container_id..."
    docker stop $container_id
    rm -f docker.pid
fi

# Start the xpaas docker container
echo "Starting $CONTAINER_NAME docker container using:"
echo "** Container name: $CONTAINER_NAME"
image_xpaas_bpmsuite=$(docker run $CONTAINER_LINKING -P -d --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_TAG)
ip_bpmsuite=$(docker inspect $image_xpaas_bpmsuite | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_bpmsuite > docker.pid

# End
echo ""
echo "Server starting in $ip_bpmsuite"
echo "You can access the server root context in http://$ip_bpmsuite:8080"
echo "JBoss BPM Suite is running at http://$ip_bpmsuite:8080/business-central"

exit 0