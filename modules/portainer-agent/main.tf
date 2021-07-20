

data "docker_registry_image" "agent" {
  name = "portainer/agent:latest"
}

resource "docker_image" "agent" {
  name          = data.docker_registry_image.agent.name
  pull_triggers = [data.docker_registry_image.agent.sha256_digest]
}

// this presumes the tailscale network is up and working
# docker run -d \
#   -v /var/run/docker.sock:/var/run/docker.sock \
#   -v /var/lib/docker/volumes:/var/lib/docker/volumes \
#   -v /:/host \
#   -v portainer_agent_data:/data \
#   --restart always \
#   -e EDGE=1 \
#   -e EDGE_ID=05751624-1150-45d2-b254-c4d41d6c2a9e \
#   -e EDGE_KEY=aHR0cDovLzEwMC43Mi43OS43NXwxMDAuNzIuNzkuNzU6ODAwMHxiNjpmNTowNDo3MzowZTpmYToyYzo3NzpkYzowZjo5Mzo4Yzo1Mjo1Yjo3NDplM3w2 \
#   -e CAP_HOST_MANAGEMENT=1 \
#   --name portainer_edge_agent \
#   portainer/agent
resource "docker_container" "portainer_edge_agent" {
  name  = "portainer_edge_agent"
  image = docker_image.agent.latest
  privileged = true

  restart = "always"

  mounts {
      target = "/data/"
      source = "portainer_agent_data"
      type = "volume"
  }
  mounts {
      target = "/var/run/docker.sock"
      source = "/var/run/docker.sock"
      type = "bind"
  }
  mounts {
      target = "/var/lib/docker/volumes"
      source = "/var/lib/docker/volumes"
      type = "bind"
  }  
  # mounts {
  #     target = "/"
  #     source = "/host/"
  #     type = "bind"
  # }

  env = [
    "EDGE=1",
    "EDGE_ID=05751624-1150-45d2-b254-c4d41d6c2a9e",
    "EDGE_KEY=aHR0cDovLzEwMC43Mi43OS43NXwxMDAuNzIuNzkuNzU6ODAwMHxiNjpmNTowNDo3MzowZTpmYToyYzo3NzpkYzowZjo5Mzo4Yzo1Mjo1Yjo3NDplM3w2",
    "CAP_HOST_MANAGEMENT=1"
  ]
}
