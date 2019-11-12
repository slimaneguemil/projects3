Introduction

With MySQL up and running, you will execute some commands against the database to demonstrate everything is working correctly and Kubernetes can gracefully handle failures and other requests.

 
Instructions

1. Run a temporary container to use mysql to connect to the master at mysql-0.mysql and runs a few SQL commands:

kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\
  mysql -h mysql-0.mysql -e "CREATE DATABASE mydb; CREATE TABLE mydb.notes (note VARCHAR(250)); INSERT INTO mydb.notes VALUES ('k8s Cloud Academy Lab');"

The SQL commands create a mydb database with a notes table in it with one record.

 

2. Run a query using the mysql-read endpoint to select all of the notes in the table:

kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\
  mysql -h mysql-read -e "SELECT * FROM mydb.notes"

alt

 

3. Run an SQL command that outputs the MySQL server's ID to confirm that the requests are distributed to different pods:

kubectl run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\

  bash -ic "while sleep 1; do mysql -h mysql-read -e 'SELECT @@server_id'; done"

alt

Eventually, a request will be sent to each MySQL server. Recall that the master has ID of 100.

 

4. Press ctrl+c to stop the loop.

 

5. List the pods including the node name column:

kubectl get pod -o wide

alt

Notice that Kubernetes evenly distributes the pods among the worker nodes.

 

6. Enter the following command to simulate taking the node running the mysql-2 pod out of service for maintenance:

kubectl drain <NODE_NAME> --force --delete-local-data --ignore-daemonsets

where you replace <NODE_NAME> with the node name shown in the last column of the previous command's output. It will resemble ip-10-0-#-#.us-west-2.compute-internal. The drain command prevents new pods from being scheduled on the node and then evicts existing pods scheduled to it.

alt

 

7. Watch the mysql-2 pod get rescheduled to a different node:

kubectl get pod mysql-2 -o wide --watch

 

8. Uncordon the node you drained so that pods can be scheduled on it again:

kubectl uncordon <NODE_NAME>

 

9. Delete the mysql-2 pod to simulate a node failure and watch it get automatically rescheduled:

kubectl delete pod mysql-2
kubectl get pod mysql-2 -o wide --watch

alt

 

10. Press ctrl+c to stop watching the pods.

 

11. Scale the number of replicas up to 5:

kubectl scale --replicas=5 statefulset mysql

 

12. Watch as new pods get scheduled in the cluster:

kubectl get pods -l app=mysql --watch

 

13. Press ctrl+c to stop watching the pods.

 

14. Verify that you see the new MySQL server IDs:

kubectl run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\

  bash -ic "while sleep 1; do mysql -h mysql-read -e 'SELECT @@server_id'; done"

alt

 

15. Confirm that the data is replicated in the new mysql-4 pod:

kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\
  mysql -h mysql-4.mysql -e "SELECT * FROM mydb.notes"

 

16. Display the internal virtual IP of the mysql-read endpoint:

kubectl get services mysql-read

alt

Recall the mysql-read service used the default type of ClusterIP so it is only accessible inside the cluster.

 

17. Append a load balancer type to the mysql-read service declaration:

echo "  type: LoadBalancer" >> mysql-services.yaml

 

18. Apply the changes to the mysql-read service:

kubectl apply -f mysql-services.yaml

The apply command can update existing resources. It will create resources if they don't already exist. Because you created the services using the create command instead of apply you will see a warning. The warnings can be ignored for this demonstration.

 

19. Re-display the mysql-read service status:

kubectl get services mysql-read

alt

Kubernetes is in the process of provisioning an elastic load balancer (ELB) to access the mysql-read service from outside the cluster.

 

20. After a minute, describe the mysql-read service to find the DNS name of the external load balancer endpoint:

kubectl describe services mysql-read | grep "LoadBalancer Ingress"

 

21. Use the external load balancer to send some read requests to the cluster:

kubectl run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\

  bash -ic "while sleep 1; do mysql -h <EXTERNAL_LB_DNS> -e 'SELECT @@server_id'; done"

where you replace <EXTERNAL_LB_DNS> with the DNS name output by the previous command. It will resemble a830e12d78dcd11e79aba028416f4825-905974806.us-west-2.elb.amazonaws.com. You are now accessing the cluster from the ELB which provides access outside of the cluster.

Note: It can take a minute for the nodes to be added to the load balancer. You will see unknown MySQL host messages until the nodes are added. Let the loop continue to run until you start seeing server IDs being displayed.

 

22. Press ctrl+c to stop the temporary container.

 
Summary 

In this Lab Step, you worked with the MySQL stateful application to demonstrate:

    How to directly address pods in the cluster
    How to access the cluster via the mysql-read service
    How to take nodes out of service
    How Kubernetes automatically recovers from a simulated node failure
    How to permit access to the mysql-read service via an automatically provisioned ELB
