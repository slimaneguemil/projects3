Introduction

Stateful applications are applications that have a memory of what happened in the past. Databases are an example of stateful applications. Kubernetes provides support for stateful applications through StatefulSets and related primitives.

This Lab will deploy a replicated MySQL database as a StatefulSet. MySQL is one of the most popular databases in the world. This Lab won't focus on the details specific to configuring MySQL. The focus is on the features of Kubernetes that allow a stateful application to be deployed. The Kubernetes community maintains a wide variety of stateful applications that are ready to deploy through Helm. Helm acts like a package manager for Kubernetes and can deploy entire applications to a cluster using templates called charts. A list of charts is available here. In addition to MySQL, there are charts for many other popular databases including MongoDB and PostgreSQL, as well as popular applications like WordPress and Joomla. The concepts illustrated in this Lab will help you understand the common elements used to deploy all of these stateful applications in Kubernetes.

Managing your stateless and stateful applications with the Kubernetes provides efficiencies and simplifies automation. However, before using StatefulSets for your own stateful applications, you should consider if any of the following apply:

    You embrace microservices
    You frequently create new service footprints that include stateful applications
    Your current solution for storing state can't scale to meet predicted demand
    Your stateful applications can meet performance requirements without using specialized hardware and could effectively run on the same hardware used for stateless applications
    You value flexible reallocation of resources, consolidation, and automation over squeezing the most and having highly predictable performance

If any of the previous bullets apply to your situation, it may make sense to use Kubernetes for your stateful applications.

 

There are quite a few concepts at work in this Lab Step. Begin by reviewing the following background section and then jump into the instructions.

 
Background

ConfigMaps: A type of Kubernetes resource that is used to decouple configuration artifacts from image content to keep containerized applications portable. The configuration data is stored as key-value pairs.

 

Headless Service: A headless service is a Kubernetes service resource that won't load balance behind a single service IP. Instead, a headless service returns list of DNS records that point directly to the pods that back the service. A headless service is defined by declaring the clusterIP property in a service spec and setting the value to None. StatefulSets currently require a headless service to identify pods in the cluster network.

 

Stateful Sets: Similar to Deployments in Kubernetes, StatefulSets manage the deployment and scaling of pods given a container spec. StatefulSets differ from Deployments in that they each pod in a StatefulSet is not interchangeable. Each pod in a StatefulSet has a persistent identifier that it maintains across any rescheduling. The pods in a StatefulSet are also ordered. This provides a guarantee that one pod can be created before following pods. In this Lab, this is useful for ensuring the master is provisioned first.

 

PersistentVolumes (PVs) and PersistentVolumeClaims (PVCs): PVs are Kubernetes resources that represent storage in the cluster. Unlike regular Volumes which exist only until while containing pod exists, PVs do not have a lifetime connected to a pod. Thus, they can be used by multiple pods over time, or even at the same time. Different types of storage can be used by PVs including NFS, iSCSI, and cloud provided storage volumes, such as AWS EBS volumes. Pods claim PV resources through PVCs.

 

MySQL replication: This Lab uses a single master, asynchronous replication scheme for MySQL. All database writes are handled by the single master. The database replicas asynchronously synchronize with the master. This means the master will not wait for the data to be copied onto the replicas. This can improve the performance of the master at the expense of having replicas that are not always exact copies of the master. Many applications can tolerate slight differences in the data and are able to improve the performance of database read workloads by allowing clients to read from the replicas.

 
Instructions

1. In the master node SSH shell, enter the following to declare a ConfigMap 
to allow master MySQL pods to be configured differently than replica pods:

cat <<EOF > mysql-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
data:
  master.cnf: |
   # Apply this config only on the master.
   [mysqld]
   log-bin
  slave.cnf: |
    # Apply this config only on slaves.
    [mysqld]
    super-read-only
EOF

This ConfigMap will be referenced later in the StatefulSet declaration. The master.cnf key maps to a value that declares a MySQL configuration which includes replication logs. The slave.cnf key maps to a MySQL configuration that enforces read-only behavior.

 

2. Create the ConfigMap resource:

kubectl create -f mysql-configmap.yaml

 

3. Enter the following command to declare the services for the MySQL application:

cat <<EOF > mysql-services.yaml
# Headless service for stable DNS entries of StatefulSet members.
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  clusterIP: None
  selector:
    app: mysql
---
# Client service for connecting to any MySQL instance for reads.
# For writes, you must instead connect to the master: mysql-0.mysql.
apiVersion: v1
kind: Service
metadata:
  name: mysql-read
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  selector:
    app: mysql
EOF

Two services are defined:

    A headless service (clusterIP: None) for pod DNS resolution. Because the service is named mysql, pods are accessible via pod-name.mysql.
    A service name mysql-read to connect to for database reads. 
    This service uses the default ServiceType of ClusterIP which assigns an internal IP address that load balances request to all the pods labeled with app: mysql.

Database writes need to be sent to the master. The master is the first pod provisioned in the StatefulSet and assigned a name mysql-0.
 The pod is thus accessed by the DNS entry in the headless service for mysql-0.mysql.

 

4. Create the MySQL services:

kubectl create -f mysql-services.yaml

 

5. Enter the following command to declare a default storage class that will be used to dynamically provision general purpose (gp2) EBS volumes for the Kubernetes PVs:

cat <<EOF > mysql-storageclass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: general
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
EOF

The built-in aws-ebs storage provision is specified along with the type gp2.

 

6. Create the storage class:

kubectl create -f mysql-storageclass.yaml

 

7. Enter the following command to declare the MySQL StatefulSet:

cat <<'EOF' > mysql-statefulset.yaml
apiVersion: apps/v1beta2
kind: StatefulSet
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  serviceName: mysql
  replicas: 3
  template:
    metadata:
      labels:
        app: mysql
    spec:
      initContainers:
      - name: init-mysql
        image: mysql:5.7
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Generate mysql server-id from pod ordinal index.
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          echo [mysqld] > /mnt/conf.d/server-id.cnf
          # Add an offset to avoid reserved server-id=0 value.
          echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
          # Copy appropriate conf.d files from config-map to emptyDir.
          if [[ $ordinal -eq 0 ]]; then
            cp /mnt/config-map/master.cnf /mnt/conf.d/
          else
            cp /mnt/config-map/slave.cnf /mnt/conf.d/
          fi
        volumeMounts:
        - name: conf
          mountPath: /mnt/conf.d
        - name: config-map
          mountPath: /mnt/config-map
      - name: clone-mysql
        image: gcr.io/google-samples/xtrabackup:1.0
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Skip the clone if data already exists.
          [[ -d /var/lib/mysql/mysql ]] && exit 0
          # Skip the clone on master (ordinal index 0).
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          [[ $ordinal -eq 0 ]] && exit 0
          # Clone data from previous peer.
          ncat --recv-only mysql-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql
          # Prepare the backup.
          xtrabackup --prepare --target-dir=/var/lib/mysql
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "1"
        ports:
        - name: mysql
          containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        livenessProbe:
          exec:
            command: ["mysqladmin", "ping"]
          initialDelaySeconds: 30
          timeoutSeconds: 5
        readinessProbe:
          exec:
            # Check we can execute queries over TCP (skip-networking is off).
            command: ["mysql", "-h", "127.0.0.1", "-e", "SELECT 1"]
          initialDelaySeconds: 5
          timeoutSeconds: 1
      - name: xtrabackup
        image: gcr.io/google-samples/xtrabackup:1.0
        ports:
        - name: xtrabackup
          containerPort: 3307
        command:
        - bash
        - "-c"
        - |
          set -ex
          cd /var/lib/mysql

          # Determine binlog position of cloned data, if any.
          if [[ -f xtrabackup_slave_info ]]; then
            # XtraBackup already generated a partial "CHANGE MASTER TO" query
            # because we're cloning from an existing slave.
            mv xtrabackup_slave_info change_master_to.sql.in
            # Ignore xtrabackup_binlog_info in this case (it's useless).
            rm -f xtrabackup_binlog_info
          elif [[ -f xtrabackup_binlog_info ]]; then
            # We're cloning directly from master. Parse binlog position.
            [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
            rm xtrabackup_binlog_info
            echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\
                  MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in
          fi

          # Check if we need to complete a clone by starting replication.
          if [[ -f change_master_to.sql.in ]]; then
            echo "Waiting for mysqld to be ready (accepting connections)"
            until mysql -h 127.0.0.1 -e "SELECT 1"; do sleep 1; done

            echo "Initializing replication from clone position"
            # In case of container restart, attempt this at-most-once.
            mv change_master_to.sql.in change_master_to.sql.orig
            mysql -h 127.0.0.1 <<EOF
          $(<change_master_to.sql.orig),
            MASTER_HOST='mysql-0.mysql',
            MASTER_USER='root',
            MASTER_PASSWORD='',
            MASTER_CONNECT_RETRY=10;
          START SLAVE;
          EOF
          fi

          # Start a server to send backups when requested by peers.
          exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \
            "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root"
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 100m
            memory: 50Mi
      volumes:
      - name: conf
        emptyDir: {}
      - name: config-map
        configMap:
          name: mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 2Gi
      storageClassName: general
EOF

There is a lot going on in the StatefulSet. Don't focus too much on the bash scripts that are performing MySQL specific tasks. Some highlights to focus on, following the order they appear in the file are:

    init-containers: Run to completion before any containers in the Pod spec
        init-mysql: Assigns a unique MySQL server ID starting from 100 for the first pod and incrementing by one, as well as copying the appropriate configuration file from the config-map. Note the config-map is mounted via the VolumeMounts section. The ID and appropriate configuration file are persisted on the conf volume.
        clone-mysql: For pods after the master, clone the database files from the preceding pod. The xtrabackup tool performs the file cloning and persists the data on the data volume.
    spec.containers: Two containers in the pod
        mysql: Runs the MySQL daemon and mounts the configuration in the conf volume and the data in the data volume
        xtrabackup: A sidecar container that provides additional functionality to the mysql container. It starts a server to allow data cloning and begins replication on slaves using the cloned data files.
    spec.volumes: conf and config-map volumes are stored on the node's local disk. They are easily re-generated if a failure occurs and don't require PVs.
    volumeClaimTemplates: A template for each pod to create a PVC with. ReadWriteOnce accessMode allows the PV to be mounted by only one node at a time in read/write mode. The storageClassName references the AWS EBS gp2 storage class named general that you created earlier. 

 

8. Create the StatefulSet and start watching the associated pods:

kubectl create -f mysql-statefulset.yaml
kubectl get pods -l app=mysql --watch

The --watch option causes any updates to the pods to be written to the output. It takes a few minutes to initialize all three replicas.

 

9. While the pods are getting ready, return to the AWS EC2 Console and select ELASTIC BLOCK STORE > Volumes.

The 2GiB PVs are listed here as each pod is created. Notice the Name and Tags which relay information about the PV and associated PVC.


10. Return to your SSH shell and press ctrl+C to stop the watch when you see both containers (2/2) in the mysql-2 pod running: 


11. Describe the PVs and PVCs:

kubectl describe pv | more
kubectl describe pvc | more

The PV descriptions include the AWS VolumeIDs, file system types (FSType), and associated PVC (Claim). The PVC description includes whether the PVC is currently Bound to a pod.

 

12. Get the StatefulSet to confirm the current number of replicas matches the desired:

kubectl get statefulset

 
Summary 

In this Lab Step, you created several Kubernetes cluster resources to deploy the MySQL database as an example stateful application:

    A ConfigMap for decoupling master and slave configuration from the containers
    Two Services: one headless service to manage network identity of pods in the StatefulSet, and one to load balance read access to the MySQL replicas
    A StorageClass to provision EBS PVs dynamically
    A StatefulSet that declared two init-containers, two containers, and one PVC template

You observed the ordered sequence of pods being initialized and the PVs created in AWS to faciliate the StatefulSet.