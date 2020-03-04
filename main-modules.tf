provider "azurerm" {
  version = "=1.44.0"
}

resource "azurerm_resource_group" "myresourcegroup" {
  name     = "${var.prefix}-workshop"
  location = var.location
}

module "web-app-container" {
  source  = "app.terraform.io/HashiCorp-Sam/web-app-container/azurerm"
  version = "2.6.0"
  name = "${var.prefix}-app"
  port = "80"
  https_only = "false"
  resource_group_name = "${azurerm_resource_group.myresourcegroup.name}"
  container_type = "docker"
  container_image = "scarolan/palacearcade"
}

