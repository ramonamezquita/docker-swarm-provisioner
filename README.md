# Deploy a Docker Swarm Cluster on GCP

## Usage

```bash
./deplpy.sh -K <ssh_key_file> [-C <instance_count>]
```

The `-K` and `-C` options corresponding to the private ssh key file and instance count (number of nodes in the cluster), respectively,
are propagated to the `terraform apply` command. The remaining variables need to be set using the `terraform.tfvars` file. These include
region, zone, project_id, etc.


To see helper message:

```bash
./deploy.sh --help

usage: deploy.sh -K <ssh_key_file> [-C <instance_count>]            
       -K, --key-file <file>        - SSH private key file.     
       -C, --instance-count <int>   - Instance count. Default 3.
       -h, --help                   - Show this help message.   
                                                                
example:                                                        
  ./deploy.sh -K ~/.ssh/gcp_key -C 5 
```
# gcp-docker-swarm
