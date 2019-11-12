k run nginx --image=nginx --restart=Never --labels=app=v1 --dry-run -o yaml
describe po nginx | grep -i 'annotations'

k annotate po nginx1 nginx2 nginx3 description='my description' --overwrite 
k annotate po nginx{1..3} description-

kubectl run nginx --image=nginx:1.7.8 --replicas=2 --port=80

 k get rs -l run=nginx
  k get rs -l app=nginx
  
  kubectl scale deploy nginx --replicas=5
  
  kubectl autoscale deploy nginx --min=5 --max=10 --cpu-percent=80
  
  kubectl set image deploy nginx nginx=nginx:1.9.1
  
  kubectl create job pi  --image=perl -- perl -Mbignum=bpi -wle 'print bpi(2000)'
  
  ubectl create job busybox --image=busybox -- /bin/sh -c 'echo hello;sleep 30;echo world'
  
  k logs job/b 
  
  k create cronjob busybox --image=busybox --schedule="*/1 * * * *" -- /bin/sh -c 'date; echo Hello from the Kube
  rnetes cluster'