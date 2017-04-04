# kubernetes-fluentd

Kubernetes Logger is designed to take all of the logs from your containers and system and forward them to a central location. Today this can be a S3 bucket in AWS or a ElasticSearch cluster (or both). The logger is intended to be a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) which will run a pod on each Node in your cluster. Fluentd is the forwarder agent which has a configuration file to configure the different output destinations for your logs. 

Currently the sample container has both the S3 plugin as well as the Elasticsearch plugin installed by default. Please customize the `fluent.conf` to your satisfaction to enable or disable one or the other. 

## Deployment

Deployment to a Kubernetes cluster is maintained by a DaemonSet. The DaemonSet requires a ConfigMap to pass parameters to the DaemonSet. 

Configmap Parameters:
- AWS_S3_BUCKET_NAME: {YOUR_BUCKET}
- AWS_S3_LOGS_BUCKET_PREFIX: fluentd-logs
- AWS_S3_LOGS_BUCKET_REGION: us-east-1
- ELASTICSEARCH_HOST: elasticsearch-logging
- ELASTICSEARCH_PORT: "9200"

#### Create the configmap + daemonset:
```
kubectl create -f https://raw.githubusercontent.com/upmc-enterprises/kubernetes-fluentd/master/fluentd-configmap.yaml
kubectl create -f https://raw.githubusercontent.com/upmc-enterprises/kubernetes-fluentd/master/fluentd.yaml
```

## AWS Setup (If using S3)

The pod running as the daemonset requires permissions to access the S3 bucket defined in the configmap. Configure an IAM role for your EC2 instances with a proper policy. 

### Example Policy:
```json
{
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucketVersions"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::{YOUR_BUCKET}"
            ]
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::{YOUR_BUCKET}/*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
```

# Deploy ELK Stack

For a simple ELK stack to get started, deploy the following:

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-controller.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-service.yaml
kubectl create -f https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/fluentd-elasticsearch/kibana-controller.yaml
kubectl create -f https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/fluentd-elasticsearch/kibana-service.yaml
```
_Source: https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch_

# About

Built by UPMC Enterprises in Pittsburgh, PA. http://enterprises.upmc.com/