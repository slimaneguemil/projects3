k create deployment --image=httpd:2.4.38 web-server --dry-run -o yaml
k create deployment --image=httpd:2.4.38 web-server
k scale deploy web-server --replicas=6
k rollout history deploy web-server
k edit deploy web-server --record
k rollout status web-server
kk rollout status deploy web-server
k set image deploy web-server httpd=httpd:2.4.38-alpine --record
k rollout undo deploy web-server
k expose dep


k create job one-off --image=alpine -- sleep 30
k get jobs one-off -o yaml | more

watch describe jobs pod-fail
k get events -w

** cronjob
* observe 1 pod created every minute
 k describe cronjob cronjob-example