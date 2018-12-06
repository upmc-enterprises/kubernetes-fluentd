# kubernetes-fluentd

Kubernetes Logger is designed to take all of the logs from your containers and system and forward them to a central location. Today this can be a S3 bucket in AWS or a ElasticSearch cluster (or both). The logger is intended to be a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) which will run a pod on each Node in your cluster. Fluentd is the forwarder agent which has a configuration file to configure the different output destinations for your logs. 

Currently the sample container has both the S3 plugin as well as the Elasticsearch plugin installed by default. Please customize the `fluent.conf` to your satisfaction to enable or disable one or the other. 

## Deployment

Deployment to a Kubernetes cluster is maintained by a DaemonSet. The DaemonSet requires a ConfigMap to pass parameters to the DaemonSet. 

1. Create bucket in S3 changing the value of 'steve_bucket' to your unique bucket name:
    ```
    $ aws s3api create-bucket --bucket steve_bucket --region us-east-1
    ```

2. Edit the file 's3_iam_role.json' and update the value '{YOUR_BUCKET}' with the value of the bucket created in the previous step. In the following example my bucket name is 'steve_bucket':
    ```
    $ sed 's/{YOUR_BUCKET}/steve_bucket/g' s3_iam_role.json > s3_iam_role_complete.json
    ```

3. Create an IAM policy to allow access to the S3 bucket:
    ```
    $ aws iam create-policy --policy-name kubernetes-fluentd-s3-logging --policy-document file://s3_iam_role_complete.json
    ```

4. Attach the policy to the IAM Role for the Kubernetes workers:
    ```
    # Find RoleName for the worker role
    $ aws iam list-roles | grep -i iamroleworker
    
    # Attach policy
    $ aws iam attach-role-policy --policy-arn <ARN_of_policy_created_in_previous_step> --role-name <RoleName>
    Create the ConfigMap specifying the correct values for your environment:
    $ kubectl create configmap fluentd-conf --from-literal=AWS_S3_BUCKET_NAME=<!YOUR_BUCKET_NAME!> --from-literal=AWS_S3_LOGS_BUCKET_PREFIX=<!YOUR_BUCKET_PREFIX!>  --from-literal=AWS_S3_LOGS_BUCKET_PREFIX_KUBESYSTEM=<!YOUR_BUCKET_PREFIX!> --from-literal=AWS_S3_LOGS_BUCKET_REGION=<!YOUR_BUCKET_REGION!> --from-file=fluent_s3.conf -n kube-system
    ```
    
    | Variable      | Description
    | ------------- |-------------| 
    | AWS_S3_BUCKET_NAME | Name of the S3 bucket 
    | AWS_S3_LOGS_BUCKET_PREFIX      | The prefix to place the application logs into (e.g. k8s-logs/logs/)  
    | AWS_S3_LOGS_BUCKET_PREFIX_KUBESYSTEM | The prefix to place the system logs into (e.g. k8s-logs/kubesystem-logs/)
    | AWS_S3_LOGS_BUCKET_REGION | AWS Region


5. Deploy the daemonset:
    ```
    $ kubectl create -f https://raw.githubusercontent.com/markyjackson-taulia/kubernetes-fluentd/master/k8s/fluentd_s3.yaml
    ```

6.  Verify logs are writing to S3:
    ```
    $ aws s3api list-objects --bucket steve_bucket
    ```

# Deploy ELK Stack

For a simple ELK stack to get started, deploy the following:

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-controller.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-service.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-controller.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-service.yaml
```
_Source: https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch_

# About

Built by UPMC Enterprises in Pittsburgh, PA. http://enterprises.upmc.com/