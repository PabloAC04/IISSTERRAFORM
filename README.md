# IISSTERRAFORM
# Documentación de Terraform para despliegue de WordPress y MariaDB con Docker

Este conjunto de archivos de Terraform permite configurar y desplegar un entorno que incluye WordPress y una base de datos MariaDB, utilizando contenedores Docker.

## Archivos

### `docker.tf`

```hcl
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
```

####A destacar
- **Proveedor Terraform para Docker**: Configura el proveedor `docker` con la versión específica requerida para gestionar recursos de Docker.
- **Recursos Docker**:
  - `docker_network` crea una red Docker que permite la comunicación entre los contenedores de WordPress y MariaDB.
  - `docker_volume` define un volumen para la persistencia de los datos de MariaDB.
  - `docker_image` para MariaDB y WordPress descarga las imágenes de Docker necesarias.
  - `docker_container` para MariaDB y WordPress configura y ejecuta los contenedores, incluyendo variables de entorno para la base de datos y mapeo de puertos para WordPress.


### `variables.tf`

```hcl
variable "mariadb_root_password" {
  description = "La contraseña de root para MariaDB"
  type        = string
}

variable "wp_db_name" {
  description = "Nombre de la base de datos de WordPress"
  type        = string
}

variable "wp_db_user" {
  description = "El usuario de la base de datos para WordPress"
  type        = string
}

variable "wp_db_password" {
  description = "La contraseña para el usuario de la base de datos de WordPress"
  type        = string
}
```
####A destacar

Se definen variables para configurar dinámicamente los contenedores de MariaDB y WordPress:
- **mariadb_root_password**: Contraseña del usuario root para MariaDB.
- **wp_db_name**: Nombre de la base de datos que utilizará WordPress.
- **wp_db_user**: Usuario de la base de datos para WordPress.
- **wp_db_password**: Contraseña para el usuario de la base de datos de WordPress.


### `terraform.tfvars`

```hcl
mariadb_root_password = "wordpress"
wp_db_name            = "wordpress"
wp_db_user            = "wordpress"
wp_db_password        = "wordpress"
```

####A destacar

Este archivo proporciona valores predeterminados para las variables definidas en `variables.tf`, lo que facilita la inicialización y configuración rápida del entorno de despliegue. Los valores son:
- `mariadb_root_password`, `wp_db_name`, `wp_db_user`, `wp_db_password`: Configurados para un entorno de prueba con el valor "wordpress". Estos valores deben ser cambiados en entornos de producción por razones de seguridad.

## Uso

Para utilizar esta configuración de Terraform:

1. Asegúrate de tener Terraform y Docker instalados en tu máquina.
2. Ejecuta `terraform init` para inicializar el directorio de trabajo de Terraform.
3. Aplica la configuración con `terraform apply`. Se te solicitará confirmación antes de proceder.
4. Una vez aplicada la configuración, WordPress estará disponible en `http://localhost:8000`.

