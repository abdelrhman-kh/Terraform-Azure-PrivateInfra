# Output the MySQL server name
output "mysql_server_name" {
  value = azurerm_mysql_flexible_server.mysql_server.name
}

output "admin_login" {
  sensitive = true
  value     = azurerm_mysql_flexible_server.mysql_server.administrator_login
}

output "admin_password" {
  sensitive = true
  value     = azurerm_mysql_flexible_server.mysql_server.administrator_password
}