# Outputs file
// output "catapp_url" {
//   value = "http://${azurerm_public_ip.catapp-pip.fqdn}"
// }

output "container_app_url" {
   value = "http://${module.web_app_container.hostname}"
}