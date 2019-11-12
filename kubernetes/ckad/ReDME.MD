ssh-add -k *.pem 
ssh -A ubuntu@BASTION_IP
scp -o "ForwardAgent yes" ubuntu@master_ip:~/kubeconfig ~/.kube/config

source <(kubectl completion bash) 

*** setup metrics

# Load completions
source <(kubectl completion bash)
# Download and install Metrics Server
wget -qO /tmp/metrics-server.zip https://github.com/cloudacademy/metrics-server/archive/master.zip
sudo apt install unzip && \
  unzip -q -d /tmp /tmp/metrics-server.zip && \
  kubectl create -f /tmp/metrics-server-master/deploy/1.8+/