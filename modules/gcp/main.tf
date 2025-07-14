provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.1"

  project_id   = var.project_id
  network_name = "swarm-vpc"

  subnets = [
    {
      subnet_name   = "swarm-subnet"
      subnet_ip     = "10.0.1.0/24"
      subnet_region = var.region
    }
  ]

  ingress_rules = [
    {
      name          = "allow-ssh"
      description   = "Allow SSH from anywhere"
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]

        }
      ]
    },
    {
      name          = "allow-swarm-tcp"
      description   = "Allow Swarm TCP traffic"
      source_ranges = ["10.0.0.0/16"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["2377", "7946"]

        }
      ]
    },
    {
      name          = "allow-swarm-udp"
      description   = "Allow Swarm UDP traffic"
      source_ranges = ["10.0.0.0/16"]
      allow = [
        {
          protocol = "udp"
          ports    = ["4789"]

        }
      ]
    }
  ]


  egress_rules = [
    {
      name               = "allow-all-egress"
      description        = "Allow all outbound traffic"
      destination_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
        }
      ]
    }
  ]
}


resource "google_compute_instance" "vms" {
  count        = var.instance_count
  machine_type = var.instance_type
  zone         = var.zone
  name         = "swarm-node-${count.index}"
  tags         = ["swarm-node"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_pub_key_file)}"
  }

  network_interface {
    subnetwork = module.vpc.subnets["${var.region}/swarm-subnet"].name
    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  # The local-exec provisioner runs without waiting for the VM to become available, 
  # so the execution of the playbook may precede the actual availability of the VM. 
  # To remedy this, we define the remote-exec provisioner to contain commands to execute 
  # on the target server. For remote-exec to execute, the target server must be available. 
  # Since remote-exec runs before local-exec, the server will be fully initialized by the 
  # time Ansible is invoked. 
  provisioner "remote-exec" {
    inline = ["sudo apt update", "echo Done!"]

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_pvt_key_file)
    }
  }

  # Install docker.
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${self.network_interface.0.access_config.0.nat_ip},' --private-key ${var.ssh_pvt_key_file} ansible/docker-install.yml"
  }
}