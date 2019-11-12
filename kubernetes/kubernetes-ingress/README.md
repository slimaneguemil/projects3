# kubernetes-ingress
differents projects involving implementation of ingress in a kubernetes cluster.


##create cluster 
aws s3 mb s3://cluster-kops.nosiris.com
export KOPS_STATE_STORE=s3://cluster-kops.nosiris.com
kops create cluster --kubernetes-version=v1.13.9 --cloud=aws --dns-zone=nosiris.com  --zones=eu-central-1a   --name kops.nosiris.com --node-size=t2.medium  --node-count=1 --master-size=t2.small  --ssh-public-key=~/.ssh/guemils_frank.pub --admin-access "188.61.251.150/32" --yes
kops delete cluster kops.nosiris.com

#kubectl version d be compatible with k8s version
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.13.1/bin/linux/amd64/kubectl
chmod +x ./kubectl
whereis kubectl
cp ./kubectl /usr/local/bin/kubectl 
cp ./kubectl /snap/bin/kubectl

## create manually a recordset *.nosiris.com -> ELB

# install nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/ingress-nginx/v1.6.0.yaml



##  LAB demo_echo
kubectl run echoheaders --image=k8s.gcr.io/echoserver:1.4 --replicas=1 --port=808
kubectl expose deployment echoheaders --port=80 --target-port=8080 --name=echoheaders-x
kubectl expose deployment echoheaders --port=80 --target-port=8080 --name=echoheaders-y

kubectl apply -f demo_echo/ingress.yaml

##  LAB demosnginx
#deploy 3 nginx services
for i in nginxhello-3yaml; do kubectl apply -f $i; done
kubectl apply -f demos_nginx/ingress-scenarios/blue.yaml
#test kops.nosiris.com
kubectl apply -f demos_nginx/ingress-scenarios/blue_red.yaml
#test red.kops.nosiris.com
#test blue.kops.nosiris.com