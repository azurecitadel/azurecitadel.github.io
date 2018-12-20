#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Please use $0 CLUSTER_NAME RESOURCE_GROUP"
    exit 1
fi

KUBE_CLUSTER=$1
RESOURCE_GROUP=$2

az aks get-credentials -n ${KUBE_CLUSTER} -g ${RESOURCE_GROUP}
if [ $? -eq 0 ]; then
    helm init

    # Need to sleep to allow tiller to spin up
    sleep 10

    az aks install-connector --resource-group ${RESOURCE_GROUP} --name ${KUBE_CLUSTER} --connector-name aciconnector
else
    echo "Cannot find Kubernetes cluster or Resource group"
fi