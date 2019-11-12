k create namespace secrets

k create secret generic app-secret --from-literal=password=1234567 
# decode & dislpay password
k get secret app-secret -o jsonpath="{.data.password}" | base64 --decode && echo
k exec pod-secret -- /bin/sh -c 'echo $PASSWORD' 