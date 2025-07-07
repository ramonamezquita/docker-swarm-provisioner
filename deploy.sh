#!/bin/bash

# -----------------------------------------------------------------------------
# GCP Docker Swarm Cluster Provisioning Script
# -----------------------------------------------------------------------------
#
# Description:
#   This script automates the provisioning of a Docker Swarm cluster on Google
#   Cloud Platform (GCP) using Terraform for infrastructure deployment and
#   Ansible for cluster configuration.
#
# Features:
#   - Creates specified number of VM instances (minimum 2)
#   - Initializes a Docker Swarm cluster with 1 manager and N-1 workers
#   - Uses Terraform for infrastructure-as-code deployment
#   - Uses Ansible for configuration management
#
# Usage:
#   ./deploy.sh -K <ssh_key_file> [-C <instance_count>]
#
#
# Example:
#   ./deploy.sh -K ~/.ssh/gcp_key -C 5
# -----------------------------------------------------------------------------


set -e 

DEFAULT_INSTANCE_COUNT=3


usage() {
  echo "usage: $PROG -K <ssh_key_file> [-C <instance_count>]            "
  echo "       -K, --key-file <file>        - SSH private key file.     "
  echo "       -C, --instance-count <int>   - Instance count. Default 3."
  echo "       -h, --help                   - Show this help message.   "
  echo "                                                                "
  echo "example:                                                        "
  echo "  ./deploy.sh -K ~/.ssh/gcp_key -C 5                            "
}



define_groups() {
  managers_count=$1
  sed -e '1s/^/[managers] \n/' -e "$[managers_count+1]s/^/[workers] \n/"
}


parse_args() {
  if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    exit 1
  fi


  while [ $# -gt 0 ]; do
    case "$1" in
      -K|--key-file)
        key_file="$2"
	shift 2
	;;
      -C|--instance-count)
        instance_count=$2
	shift 2
	;;
      -h|--help)
	usage
	exit 0
	;;
      *)
       echo "Unknown option $1"
       exit 1
       ;;
    esac
  done
}

PROG=`basename $0`
parse_args "$@"
: ${instance_count:=$DEFAULT_INSTANCE_COUNT}

if [ $instance_count -lt 2 ]; then
  echo "Error: Instance count must be at least 2."
  exit 1
fi

echo "Running with args {"key_file":${key_file}, "instance_count":${instance_count}}."


terraform init
terraform apply -auto-approve -var "instance_count=${instance_count}" -var "ssh_pvt_key_file=${key_file}"
terraform output | define_groups 1 > ansible/inventory.ini
#ansible-playbook -u ubuntu --key-file ${key_file} swarm-init.yml
