#seting cluster with KOPS
export KOPS_STATE_STORE=s3://cluster-1.cluster.nosiris.com
kops update cluster --name imesh.k8s.local --yes


#or create a new cluster .
kops create cluster  --cloud=aws --zones=eu-central-1a   --name imesh.k8s.local --node-size=t2.medium  --node-count=1 --master-size=t2.small  --ssh-public-key=~/.ssh/guemils_frank.pub --admin-access " 188.61.251.150/32" --kubernetes-version=v1.13.9 --yes
kops validate cluster

#configure
   #change dea
   #fault editor vim to nano
   set EDITOR=nano
   
   
#install dashboard 
#see docs : https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml   
   #to generate a token : 1-create an account
    apply dashboard-adminuser-yaml   
   #copy the token generate by the command.     
    kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
   # create a proxy and launch the dashboard-web console, click token and copy the token
    kubectl proxy
    https://localhost:8001/ui

#Delete
kops delete cluster imesh.k8s.local  --yes


## To display your cluster manifest.
kops get --name my.example.com -o yaml 


##edit cluster
 kops edit cluster kops.nosiris.com 
 kops update cluster kops.nosiris.com --yes
 

## route 53
 dig  nosiris.com ns
 dig  + short nosiris.com ns

