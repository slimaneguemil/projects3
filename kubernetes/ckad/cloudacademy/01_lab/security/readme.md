k explain pod.spec.securityContext
k explain pod.spec.containers.securityContext

k exec pod -it --ls /dev

* run pod-no-security-context
k exec ... -it --ls /Ddev -> is limited
*run pod-security-context
k exec ... -it -- ls /dev -> is not limites
*run pod-runas
ex1:
k exec pod -it -- /bin/sh -> show $ instead off # -> it means u are not root
ex2:
inside the container . execute ps -> it show user ID is 2000 
ex3:
inside the container . execute touch /tmp/test.txt -> dispay error : read-only