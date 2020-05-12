output "leader" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.leader-pip.fqdn}"
}


output "servers" {
  value = "${formatlist("ssh %s@%s", var.admin_username, azurerm_public_ip.servers-pip[*].fqdn, )}"
}

  output "vault_ui" {
  value = "http://${azurerm_public_ip.vault-lb-pip.fqdn}:8200/"
  }
