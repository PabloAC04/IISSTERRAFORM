terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_network" "wordpress_network" {
  name = "wordpress_network"
}

resource "docker_volume" "mariadb_volume" {
  name = "mariadb_volume"
}

resource "docker_image" "mariadb_image" {
  name         = "mariadb:latest"
  keep_locally = false
}

resource "docker_container" "mariadb_container" {
  image = docker_image.mariadb_image.name
  name  = "mariadb"
  env = [
    "MYSQL_ROOT_PASSWORD=${var.mariadb_root_password}",
    "MYSQL_DATABASE=${var.wp_db_name}",
    "MYSQL_USER=${var.wp_db_user}",
    "MYSQL_PASSWORD=${var.wp_db_password}",
  ]
  volumes {
    volume_name    = docker_volume.mariadb_volume.name
    container_path = "/var/lib/mysql"
  }
  networks_advanced {
    name = docker_network.wordpress_network.name
  }
}

resource "docker_image" "wordpress_image" {
  name         = "wordpress:latest"
  keep_locally = false
}

resource "docker_container" "wordpress_container" {
  image = docker_image.wordpress_image.name
  name  = "wordpress"
  env = [
    "WORDPRESS_DB_HOST=mariadb",
    "WORDPRESS_DB_USER=${var.wp_db_user}",
    "WORDPRESS_DB_PASSWORD=${var.wp_db_password}",
    "WORDPRESS_DB_NAME=${var.wp_db_name}",
  ]
  ports {
    internal = 80
    external = 8000
  }
  networks_advanced {
    name = docker_network.wordpress_network.name
  }
  depends_on = [
    docker_container.mariadb_container,
  ]
}

