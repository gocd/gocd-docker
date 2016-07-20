This folder contains example yaml files for running GoCD in Kubernetes.  Note that at this time it uses a _static_ agent pool.

- agents.yaml - replication controller for GoCD agents
- server.yaml - replication controller for a GoCD server
- local-service.yaml - service endpoint (NodePort type) for a local Kubernetes install
- gce-service.yaml - service endpoint (LoadBalancer type) for GCE Kubernetes.

# Running
Assuming you have an existing Kubernetes cluster running, with kubectl configured:
```
kubectl create --filename server.yaml
kubectl create --filename gce-service.yaml (or local-service.yaml)
kubectl create --filename agents.yaml

```

# Note
GoCD's server container is not yet published using the image exposing /config, /artifacts, /logs volumes. In the interim server.yaml references my (@tpbrown) GoCD server image.
