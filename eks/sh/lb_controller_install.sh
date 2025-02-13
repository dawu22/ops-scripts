#!/bin/bash

cluster="prod-eks"

#curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json

##role need iam:CreatePolicy
content=$(aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json )

arn=$(echo $content | jq .Policy.Arn)
#arn="arn:aws:iam::xxxx:policy/AWSLoadBalancerControllerIAMPolicy"

#need add oidc before
eksctl create iamserviceaccount \
  --cluster=$cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=$arn \
  --approve \
  --region=ap-southeast-1


helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 


kubectl get deployment -n kube-system aws-load-balancer-controller

