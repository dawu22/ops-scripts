#!/bin/bash

cluster="prod-eks"
target="autoscaler.yaml"

curl -sLo $target https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

sed -i "s/<YOUR CLUSTER NAME>/$cluster/g" $target

kubectl apply -f $target

rm -f $target

