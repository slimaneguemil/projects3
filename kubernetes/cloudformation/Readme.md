https://github.com/heptio/aws-quickstart

http://docs.heptio.com/content/tutorials/aws-cloudformation-k8s.html

STACK=kubernetes2
aws cloudformation describe-stacks --query 'Stacks[*].Outputs[?OutputKey == `SSHProxyCommand`].OutputValue' --output text --stack-name $STACK


SSH_KEY="guemils_frank.pem"
ssh -i $SSH_KEY -A -L8080:localhost:8080 -o ProxyCommand="ssh -i \"${SSH_KEY}\" ubuntu@18.197.66.100 nc %h %p" ubuntu@10.0.5.108