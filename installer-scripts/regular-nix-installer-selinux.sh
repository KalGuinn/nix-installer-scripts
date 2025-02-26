#!/bin/bash
sudo sleep 2
echo "Adding selinux content to /nix"
sudo semanage fcontext -a -t etc_t '/nix/store/[^/]+/etc(/.*)?' ; sudo semanage fcontext -a -t lib_t '/nix/store/[^/]+/lib(/.*)?' ; sudo semanage fcontext -a -t systemd_unit_file_t '/nix/store/[^/]+/lib/systemd/system(/.*)?' ; sudo semanage fcontext -a -t man_t '/nix/store/[^/]+/man(/.*)?' ; sudo semanage fcontext -a -t bin_t '/nix/store/[^/]+/s?bin(/.*)?' ; sudo semanage fcontext -a -t usr_t '/nix/store/[^/]+/share(/.*)?' ; sudo semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?' ; sudo semanage fcontext -a -t usr_t '/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
sleep 1

echo "Temorarly setting SELinux to permissive"

sudo setenforce Permissive

sleep 1

echo "making SSL Certs"

sudo mkdir /etc/systemd/system/nix-daemon.service.d

sudo tee /etc/systemd/system/nix-daemon.service.d/override.conf <<EOF
[Service]
Environment="NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
EOF

echo "Preparing the nix install script"

sleep 5

sh <(curl -L https://nixos.org/nix/install) --daemon

echo "Nix installer has Finished running"
sleep 1
echo "Now copying service files"

sleep 1

sudo rm -f /etc/systemd/system/nix-daemon.{service,socket} ; sudo cp /nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.{service,socket} /etc/systemd/system/ ; sudo restorecon -RF /nix ; sudo systemctl daemon-reload ; sudo systemctl enable --now nix-daemon.socket

sleep 1

echo "Now setting SELinux back to Enforcing"

sudo setenforce Enforcing

sleep 1

echo "Making a nix backup"

bash <(curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/backup-scripts/create-backup-selinux.sh)

sleep 1

bash <(curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/other-scripts/nix-linker.sh)

echo "Modifying configurations"

sleep 1

sudo rm -f /etc/nix/nix.conf ; sudo wget -P /etc/nix https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/other-files/nix.conf
sudo rm -f /etc/profile.d/nix-app-icons.sh ; sudo wget -P /etc/profile.d https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/other-files/nix-app-icons.sh

sleep 1

echo "Reboot your system by typing"
echo "systemctl reboot"
