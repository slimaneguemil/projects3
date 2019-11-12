#!/bin/bash
kubectl run echoheaders --image=k8s.gcr.io/echoserver:1.4 --replicas=1 --port=808
kubectl expose deployment echoheaders --port=80 --target-port=8080 --name=echoheaders-x
kubectl expose deployment echoheaders --port=80 --target-port=8080 --name=echoheaders-y
kubectl apply -f ingress.yaml

