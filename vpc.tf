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
