Introduction

The sidecar multi-container pattern uses a "sidecar" container to extend the primary container in the Pod. In the context of logging, the sidecar is a logging agent. The logging agent streams logs from the primary container, such as a web server, to a central location that aggregates logs. To allow the sidecar access to the log files, both containers mount a volume at the path of the log files. In this Lab Step, you will use an S3 bucket to collect logs. You will use a sidecar that uses Fluentd, a popular data collector often used as a logging layer, with an S3 plugin installed to stream log files in the primary container to S3.

 
Instructions

1. Store the name of the logs S3 bucket created for you by the Cloud Academy Lab environment:

s3_bucket=$(aws s3api list-buckets --query "Buckets[].Name" --output table | grep logs | tr -d \|)

 

2. Create a ConfigMap that stores the fluentd configuration file:

cat << EOF > fluentd-sidecar-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    # First log source (tailing a file at /var/log/1.log)
    <source>
      @type tail
      format none
      path /var/log/1.log
      pos_file /var/log/1.log.pos
      tag count.format1
    </source>

    # Second log source (tailing a file at /var/log/2.log)
    <source>
      @type tail
      format none
      path /var/log/2.log
      pos_file /var/log/2.log.pos
      tag count.format2
    </source>

    # S3 output configuration (Store files every minute in the bucket's logs/ folder)
    <match **>
      @type s3

      s3_bucket $s3_bucket
      s3_region us-west-2
      path logs/
      buffer_path /var/log/
      store_as text
      time_slice_format %Y%m%d%H%M
      time_slice_wait 1m
      
      <instance_profile_credentials>
      </instance_profile_credentials>
    </match>
EOF
kubectl create -f fluentd-sidecar-config.yaml

ConfigMaps allow you to separate configuration from the container images. This increases the reusability of images. ConfigMaps can be mounted into containers using Kubernetes Volumes. Explaining the fluent.conf configuration file format is outside of the scope of this Lab. Just know that two log sources are configured in the /var/log directory and their log messages will be tagged with count.format1 and count.format2. The primary container in the Pod will stream logs to those two files. The configuration also describes streaming all the logs to the S3 logs bucket in the match section.  

 

3. Create a multi-container Pod using a fluentd logging agent sidecar (count-agent): 

cat << 'EOF' > pod-counter.yaml
apiVersion: v1
kind: Pod
metadata:
  name: counter
spec:
  containers:
  - name: count
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
    - >
      i=0;
      while true;
      do
        # Write two log files along with the date and a counter
        # every second
        echo "$i: $(date)" >> /var/log/1.log;
        echo "$(date) INFO $i" >> /var/log/2.log;
        i=$((i+1));
        sleep 1;
      done
    # Mount the log directory /var/log using a volume
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  - name: count-agent
    image: lrakai/fluentd-s3:latest
    env:
    - name: FLUENTD_ARGS
      value: -c /fluentd/etc/fluent.conf
    # Mount the log directory /var/log using a volume
    # and the config file
    volumeMounts:
    - name: varlog
      mountPath: /var/log
    - name: config-volume
      mountPath: /fluentd/etc
  # Use host network to allow sidecar access to IAM instance profile credentials
  hostNetwork: true
  # Declare volumes for log directory and ConfigMap
  volumes:
  - name: varlog
    emptyDir: {}
  - name: config-volume
    configMap:
      name: fluentd-config
EOF
kubectl create -f pod-counter.yaml

The count container writes the date and a counter variable ($i) in two different log formats to two different log files in the /var/log directory every second. The /var/log directory is mounted as a Volume in both the primary count container and the count-agent sidecar so both containers can access the logs. The sidecar also mounts the ConfigMap to access the fluentd configuration file. By using a ConfigMap, the same sidecar container can be used for any configuration compared to storing the configuration in the image and having to manage separate container images for each configuration.

 

4. Navigate to the S3 Console and click the bucket with a name beginning with cloudacademylabs-k8slogs-:

alt

The bucket contains a logs folder that contains logs streamed from the sidecar every minute, according to the ConfigMap configuration file:

alt

Note: It takes a minute for the first logs to be sent to S3. If you don't see a logs folder, refresh the view after a minute.

 

5. Click one of the log files in the logs folder and then click Open from the file details view

alt

You may also need to allow the pop-up in your broswer. For example in Chrome, click Pop-up blocked in the address bar folled by the blue URL beginning with https://s3....:

alt

The file contents will resemble the following:

alt

You have confirmed that the sidecar has extended the primary container to stream its logs to S3. 

 
Summary

In this Lab Step, you used the sidecar pattern to extend a container that writes log files to stream the logs to an S3 bucket. You used a Fluentd sidecar container along with a ConfigMap to configure Fluentd. The sidecare gained access to the log files by mounting the log directory into each container using a volume. This same pattern would work for outputting to any other log aggregation system that is supported by Fluentd. 