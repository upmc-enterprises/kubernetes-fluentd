# kubernetes-fluentd

Kubernetes Logger is designed to take all of the logs from your containers and system and forward them to a central location. Today this can be a S3 bucket in AWS or a ElasticSearch cluster (or both). The logger is intended to be a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) which will run a pod on each Node in your cluster. Fluentd is the forwarder agent which has a configuration file to configure the different output destinations for your logs.

## Deployment

Deployment to a Kubernetes cluster is maintained by a DaemonSet. The DaemonSet requires a ConfigMap to pass parameters to the DaemonSet.

01. Create bucket in S3 changing the value of 'test_bucket' to your unique bucket name:
    ```
    $ aws s3api create-bucket --profile <My_Profile> --bucket test_bucket --region us-east-1
    ```

02. Edit the file 's3_iam_role.json' and update the value '{YOUR_BUCKET}' with the value of the bucket created in the previous step. In the following example my bucket name is 'test_bucket':
    ```
    $ sed 's/{YOUR_BUCKET}/test_bucket/g' s3_iam_role.json > s3_iam_role_complete.json
    ```

03. Create an IAM policy to allow access to the S3 bucket:
    ```
    $ aws iam create-policy --profile <My_Profile> --policy-name kubernetes-fluentd-s3-logging --policy-document file://s3_iam_role_complete.json
    ```

04. Attach the policy to the IAM Role for the Kubernetes workers:
    ```
    # Find RoleName for the worker role
    $ aws iam list-roles --profile <My_Profile> | grep -i iamroleworker

    # Attach policy
    $ aws iam attach-role-policy --profile <My_Profile> --policy-arn <ARN_of_policy_created_in_previous_step> --role-name <RoleName>
    ```

05. Create the ConfigMap specifying the correct values for your environment:

    We need to create a few environment variables that will hold some values used to create the config map.

    | Variable                             | Description
    | ------------------------------------ |-------------|
    | AWS_S3_BUCKET_NAME                   | Name of the S3 bucket (e.g. k8s-logs)
    | AWS_S3_LOGS_BUCKET_PREFIX            | The prefix to place the application logs into (e.g. k8s-logs/neutrino-kamioka-stg-logs/)  
    | AWS_S3_LOGS_BUCKET_PREFIX_KUBESYSTEM | The prefix to place the system logs into (e.g. k8s-logs/neutrino-kamioka-stg-kubesystem-logs/)
    | AWS_S3_LOGS_BUCKET_REGION            | AWS Region. (e.g. us-east-1)

    ```
    $ kubectl -n kube-system create configmap fluentd-conf \
        --from-literal=AWS_S3_BUCKET_NAME=<YOUR_BUCKET_NAME> \
        --from-literal=AWS_S3_LOGS_BUCKET_PREFIX=<YOUR_BUCKET_PREFIX> \
        --from-literal=AWS_S3_LOGS_BUCKET_PREFIX_KUBESYSTEM=<YOUR_BUCKET_PREFIX> \
        --from-literal=AWS_S3_LOGS_BUCKET_REGION=<YOUR_BUCKET_REGION> \
        --from-file=fluent_s3.conf
    ```

06. Deploy the daemonset:
    ```
    $ kubectl -n kube-system create -f ./k8s/fluentd_s3.yaml
    ```

07.  Verify logs are writing to S3:
    ```
    $ aws s3api list-objects --profile <My_Profile> --bucket test_bucket
    ```

## Undeployment

Help out by documenting me!!!

01. Remove DaemonSet
02.
03.
04.
05.
06.
07.




## Deploy ELK Stack

For a simple ELK stack to get started, deploy the following:

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-controller.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-service.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-controller.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-service.yaml
```
 Source: https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch


## About

Built by UPMC Enterprises in Pittsburgh, PA. http://enterprises.upmc.com/
