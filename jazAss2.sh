#!/bin/bash

# Define the user list.
users=("dennis" "aubrey" "captain" "nibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

# Set the hostname by checking what it already is.
if [ "$(hostname)" != "autosrv" ]; then
        local HOSTNAME="autosrv"
        hostnamectl set-hostname $HOSTNAME
        echo "Host name is changed"
fi
echo " Now the hostname is 'Autosrv'."
# Configure the network interface.
ip link add ens34 type ethernet
ip link set ens34 up
ip addr add 192.168.16.21/24 dev ens34
ip route add default via 192.168.16.1 dev ens34
echo 'search home.arpa localdomain' >> /etc/resolv.conf

# Install necessary software.
apt update
apt install -y openssh-server 
# Configure SSH server.
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart sshd
echo "SSH-Server has been installed properly "
apt install apache2 
echo "Apache2 has been installed properly."
apt install squid
echo "Squid has been installed properly."


# Configure firewall rules.
echo "Checking ufw rules."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3128/tcp
echo "All rules have been Applied."

# Create user accounts.
for user in ${users[@]}; do
    useradd -m -s /bin/bash $user
    ssh-keygen -t rsa -f -$user/.ssh/id_rsa -q -N ""
    ssh-keygen -t ed25519 -f -$user/.ssh/id_ed25519 -q -N ""
    cat /home/$user/.ssh/id_rsa.pub >> -$user/.ssh/authorized_keys
    cat /home/$user/.ssh/id_ed25519.pub >> -$user/.ssh/authorized_keys
    chown -R $user:$user -$user
    chmod 700 -$user/.ssh
    chmod 600 -$user/.ssh/id_rsa
    chmod 600 -$user/.ssh/id_ed25519
    chmod 644 -$user/.ssh/authorized_keys
done
echo "All users have been created successfully."
# Add given public key to 'dennis' user.
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm' >> /home/dennis/.ssh/authorized_keys

# Grant 'dennis' user sudo access.
usermod -aG sudo dennis
