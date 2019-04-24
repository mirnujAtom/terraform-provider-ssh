provider "ssh" {}

data "ssh_tunnel" "consul" {
  user            = "stefan"
  host            = "bastion.example.com"
  //private_key    = "${file(pathexpand("~/.ssh/id_rsa"))}" // use private ssh key, if not set ssh-agent is used
  //ssh_agent      = false  // do not use ssh-agent
  //ssh_agent_path = "/path" // use non-default ssh-agent socket path, needed in some scenarios like running inside docker container under MacOS
  local_address   = "localhost:0" // use port 0 to request an ephemeral port (a random port)
  remote_address  = "localhost:8500"
}

provider "consul" {
  version    = "~> 1.0"
  address    = "${data.ssh_tunnel.consul.local_address}"
  scheme     = "http"
}

data "consul_keys" "keys" {
  key {
    name = "revision"
    path = "revision"
  }
}

output "local_address" {
  value = "${data.ssh_tunnel.consul.local_address}"
}
output "random_port" {
  value = "${data.ssh_tunnel.consul.port}"
}
output "revision" {
  value = "${data.consul_keys.keys.var.revision}"
}
