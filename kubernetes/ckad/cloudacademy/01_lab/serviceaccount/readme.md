kubectl config set-context $(kubectl config current-context) --namespace=serviceaccount
kubectl create namespace serviceaccounts

#create a pod
kubectl run default-pod --generator=run-pod/v1 --image=mongo:4.0.6
kubectl get pod pod --export -o yaml

check spec.serviceaccount=default

#create new serviceaccount
kubectl create servciceaccount app-sa


k run default-pod --generator=run-pod/v1 --image=mongo:4.0.6 --serviceaccount=app-sa --dry-run -o yaml
