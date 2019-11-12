
# Create namespace
kubectl create namespace persistence
# Set namespace as the default for the current context
kubectl config set-context $(kubectl config current-context) --namespace=persistence

k get pvc
#create volumeclaim . vpc2.yml
create pod with volume attched : db.yml
write data in mongo db : 
kubectl exec db -it -- mongo testdb --quiet --eval  'db.messages.insert({"message": "I was here"}); db.messages.findOne().message'
kill/start db pod
#read data from persistent volume in moondog db :
kubectl exec db -it -- mongo testdb --quiet --eval 'db.messages.findOne().message'