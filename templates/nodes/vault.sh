#!/usr/bin/env bash


echo "==> Vault (server)"
# Vault expects the key to be concatenated with the CA
sudo mkdir -p /etc/vault.d/tls/
sudo mkdir -p /opt/vault/raft/
sudo tee /etc/vault.d/tls/vault.crt > /dev/null <<EOF
$(cat /etc/ssl/certs/me.crt)
$(cat /usr/local/share/ca-certificates/01-me.crt)
EOF

echo "==> checking if we are using enterprise binaries"
echo "==> value of enterprise is ${enterprise}"

if [ ${enterprise} == 0 ]
then
echo "--> Fetching Vault OSS"
install_from_url "vault" "${vault_url}"

else
echo "--> Fetching Vault Ent"
install_from_url "vault" "${vault_ent_url}"
fi


echo "--> Writing configuration"
sudo mkdir -p /etc/vault.d
sudo tee /etc/vault.d/config.hcl > /dev/null <<EOF


storage "raft" {
  path = "/opt/vault/raft"
  node = "${node_name}"
  retry_join {
    leader_api_addr = "http://${tpl_vault_leader_addr}:8200"
  }
}



listener "tcp" {
  address     = "0.0.0.0:8200"
  cluster_address     = "0.0.0.0:8201"
  tls_disable   = true
}


seal "azurekeyvault" {
  tenant_id      = "${tenant_id}"
  client_id      = "${client_id}"
  client_secret  = "${client_secret}"
  vault_name     = "${kmsvaultname}"
  key_name       = "${kmskeyname}"
  enviroment    = "AzurePublicCloud"
}

api_addr = "http://$(public_ip):8200"
cluster_addr = "http://$(private_ip):8201"

disable_mlock = true

ui = true

EOF

echo "--> Writing profile"
sudo tee /etc/profile.d/vault.sh > /dev/null <<"EOF"
alias vualt="vault"
EOF
source /etc/profile.d/vault.sh

echo "--> Generating systemd configuration"
sudo tee /etc/systemd/system/vault.service > /dev/null <<"EOF"
[Unit]
Description=Vault
Documentation=http://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/vault server -config="/etc/vault.d/config.hcl"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable vault
sudo systemctl start vault
sleep 8



echo "==> Vault is done!"