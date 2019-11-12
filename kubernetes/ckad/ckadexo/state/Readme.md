
#create busybox1
kubectl run busybox --image=busybox --restart=Never -o yaml --dry-run -- /bin/sh -c 'sleep 3600' > pod.yaml


#create 2 busybox
create pod.yml
#copy content file to file  inside pod/container
k exec -it busybox -c busybox1 -- /bin/sh -c "cat /etc/passwd | cut -f 1 > /etc/foo/passwd"
k exec -it busybox -c busybox2 -- bin/sh -c "cat /etc/foo/passwd"

#nib busybox2 bind with pvc
kubectl run busybox --image=busybox --restart=Never -o yaml --dry-run -- /bin/sh -c 'sleep 3600' 
#create busybox 3
# cp file to pvc afrom b2 and check from b3
k exec busybox -it -- /bin/sh -c "cat /etc/passwd | cut -f 1 -d ':' > /etc/foo/passwd"
ghost@ghost-Virtual-Machine:~/ckad/course/lab1$ k exec -it busybox2 -- /bin/sh -c "cp /etc/passwd /etc/foo/passwd"
ghost@ghost-Virtual-Machine:~/ckad/course/lab1$ k exec -it busybox3 -- /bin/sh -c "cat /etc/foo/passwd"


#copy busybox4 file to host

k cp busybox4:/etc/passwd ./passwd




