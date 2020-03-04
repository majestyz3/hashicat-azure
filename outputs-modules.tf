# Outputs file
output "container_app_url" {
   value = "http://${module.web_app_container.hostname}"
}
