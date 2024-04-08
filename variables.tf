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

