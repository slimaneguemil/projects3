kubectl create cm options --from-literal=var5=val5
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > pod.yaml
vi pod.yaml

kubectl create configmap anotherone --from-literal=var6=val6 --from-literal=var7=val7
kubectl run --restart=Never nginx --image=nginx -o yaml --dry-run > pod.yaml
vi pod.yaml

kubectl run nginx --image=nginx --restart=Never --requests='cpu=100m,memory=256Mi' --limits='cpu=200m,memory=512Mi'

echo admin > username
kubectl create secret generic mysecret2 --from-file=username

echo dXNlcm5hbWU6IGFkbWluCg== | base64 -d
k exec -it podsecret -- sh
cat /etc/foo/p*


k create serviceaccount myuser
k run nginx --image=nginx --restart=Never --serviceaccount=myuser --dry-run -o yaml

# E
describe po nginx | grep -i liveness
