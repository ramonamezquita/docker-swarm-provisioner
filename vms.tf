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
