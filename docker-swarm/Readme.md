start swarm manager
log with ssh -i /home/ghost/*frank.pem ubuntu@x.x.x.x.x

docker stack deploy -c compose-logging.yml logging

curl 'localhost:9200/_cat/indices?v'
