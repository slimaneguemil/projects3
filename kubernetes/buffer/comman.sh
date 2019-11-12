ID=$(uuidgen)
aws route53 create-hosted-zone --name cluster.nosiris.com --caller-reference $ID | jq .DelegationSet.NameServers