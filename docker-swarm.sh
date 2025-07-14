#!/bin/bash

# GCP Docker Swarm Cluster Provisioning Script
#
# This script automates the provisioning of a Docker Swarm cluster on Google
# Cloud Platform (GCP) using Terraform for infrastructure deployment and
# Ansible for cluster configuration.

set -e 


DEFAULT_NUM_INSTANCES=3
READY_TO_LAUNCH=false
READY_TO_DESTROY=false
ANSIBLE_PLAYBOOKS=("swarm-init.yml")
PROG=$(basename "$0")


usage() {
  echo "usage: $PROG --private-key PRIVATE_KEY_FILE <command>"
  echo "       --private-key PRIVATE_KEY_FILE            - SSH private key file."
  echo "commands:"
  echo "       -c NUM_INSTANCES, --create NUM_INSTANCES  - Create a Docker Swarm cluster in GCP."
  echo "       -d, --destroy                             - Destroy the cluster."
  echo "       -h, --help                                - Show this message."
  echo "examples:"
  echo "       $PROG --private-key ~/.ssh/id_rsa -c 3    - Create a cluster with 3 nodes."
  echo "       $PROG --private-key ~/.ssh/id_rsa -d      - Destroy the cluster."
}


destroy() {
  terraform destroy -auto-approve -var "ssh_pvt_key_file=$1"
  rm -f ansible/inventory.ini
}

run_playbooks() {
  for pb in ${ANSIBLE_PLAYBOOKS[@]}; do
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i ansible/inventory.ini --private-key $1 ansible/$pb
  done
}

create() {
  terraform init
  terraform apply -auto-approve -var "instance_count=$1" -var "ssh_pvt_key_file=$2"
  terraform output -raw ip_addresses | make_inventory_file 1
  run_playbooks $2
}

make_inventory_file() {
  num_managers=$1
  sed -e '1s/^/[managers] \n/' -e "$[num_managers+1]s/^/[workers] \n/" > ansible/inventory.ini
}


parse_args() {
  if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    exit 1
  fi


  while [ $# -gt 0 ]; do
    case "$1" in
      --private-key)
	if ! [ -f "$2" ]; then
	  echo "Error: PRIVATE_KEY_FILE must be a valid file."
	  exit 1
	fi
        PRIVATE_KEY_FILE="$2"
	shift 2
	;;
      -c|--create)
	READY_TO_LAUNCH=true
        NUM_INSTANCES=$2
	shift 2
	;;
      -d|--destroy)
        READY_TO_DESTROY=true
	shift
	;;
      -pb|--playbooks)
	IN="$2"
        arrIN=(${IN//;/ })
	# Append input array.
        ANSIBLE_PLAYBOOKS=( "${ANSIBLE_PLAYBOOKS[@]}" "${arrIN[@]}" )
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



parse_args "$@"
: ${NUM_INSTANCES:=$DEFAULT_NUM_INSTANCES}

if [ $NUM_INSTANCES -lt 2 ]; then
  echo "Error: Number of instances must be at least 2."
  exit 1
fi

if [ "$READY_TO_LAUNCH" = true ]; then  
  echo "Launching cluster with args: {\"PRIVATE_KEY_FILE\":\"${PRIVATE_KEY_FILE}\", \"NUM_INSTANCES\":${NUM_INSTANCES}}."
  create "$NUM_INSTANCES" "$PRIVATE_KEY_FILE"
elif [ "$READY_TO_DESTROY" = true ]; then
  echo "Destroying cluster..."
  destroy "$PRIVATE_KEY_FILE"
else
  echo "Error: Must supply either the --create or --destroy command with appropriate arguments."
  exit 1
fi
