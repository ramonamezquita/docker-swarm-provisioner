# Deploy a Docker Swarm Cluster on GCP

## Usage

```bash
./docker-swarm.sh -K ~/.ssh/id_rsa --create 3   - Create a cluster with 3 nodes.
./docker-swarm.sh -K ~/.ssh/id_rsa --destroy    - Destroy cluster.
```

The ssh private key file and number of instances (nodes in the cluster)
are propagated to the `terraform apply` command. The remaining variables 
need to be set using the `terraform.tfvars` file. These include region, zone, project id, etc.


To see helper message:

```bash
./docker-swarm.sh --help

usage: docker-swarm.sh -K <KEY_FILE> <command>
       -K KEY_FILE, --key-file KEY_FILE          - SSH private key file.
commands:
       -c NUM_INSTANCES, --create NUM_INSTANCES  - Create a Docker Swarm cluster in GCP.
       -d, --destroy                             - Destroy the cluster.
examples:
       docker-swarm.sh -K ~/.ssh/id_rsa -c 3           - Create a cluster with 3 nodes.
       docker-swarm.sh -K ~/.ssh/id_rsa -d             - Destroy the cluster.

```
