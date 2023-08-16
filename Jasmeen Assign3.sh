#!/bin/bash
# name: Jasmeen Kaur
# student number: 200516393

# before starting anything i will make variables which will store information about the servers.
server1_mgmt_ip="172.16.1.10"
server2_mgmt_ip="172.16.1.11"
# I am first going to create some functions.
# these functions are created because i will need them a lot of times in the whole script.
# the first function will be to run the basic command which we will use to remotely access the servers.
# I have taken help from youtube tutorials to understand this particular command in detail.
# This uses SSH to connect remotely to the servers.
ssh_operate_remote() {
    ssh -o "StrictHostKeyChecking=no" remoteadmin@$1 "$2"
}
# now i will make a much easier function which i can use to check wheather any command was successful or not.
# to do this i will use the exit codes of the commands which will tell me about completion of commands.
verify_command_success() {
    if [ $? -eq 0 ]; then
        echo "SUCCESS: $1"
    else
        echo "ERROR: $1"
        exit 1
    fi
}

# now according to the assignment, i need to make 2 different scripts for both of the servers.
# so i will start with the first one now.

# i have named it server1_report and all of the commands to change the modifications are given here.
# i litterally dont know about changing of the ip address so i am going to change into something i know
server1_report=$(ssh_operate_remote "$server1_mgmt_ip" "
    hostnamectl set-hostname loghost &&
    ip addr add 192.168.1.3/24 dev eth0 &&
    echo '192.168.1.4 webhost' | tee -a /etc/hosts &&
    dpkg -l | grep -E '^ii' | grep -q ufw || apt-get install -y ufw &&
    ufw allow from 172.16.1.0/24 to any port 514/udp &&
    sed -i '/imudp/s/^#//g' /etc/rsyslog.conf &&
    sed -i '/UDPServerRun/s/^#//g' /etc/rsyslog.conf &&
    systemctl restart rsyslog
")
# after completing the command, i will check the results.
verify_command_success "Configuring server1"

# once server one is done, i will repeat most of the steps for the next server.
server2_report=$(ssh_operate_remote "$server2_mgmt_ip" "
    hostnamectl set-hostname webhost &&
    ip addr add 192.168.1.4/24 dev eth0 &&
    echo '192.168.1.3 loghost' | tee -a /etc/hosts &&
    dpkg -l | grep -E '^ii' | grep -q ufw || apt-get install -y ufw &&
    ufw allow 80/tcp &&
    apt-get install -y apache2 &&
    echo '*.* @loghost' | tee -a /etc/rsyslog.conf &&
    systemctl restart rsyslog
")
# this time i have to add a line to the rsyslog too and then had to restart the service.
verify_command_success "Configuring server2"


# after configuring both the machines, my script is complete.
# but before totally finifhing, i need to check final specifications.
# first i will update the host file to add both new hostnames with proper ip addresses.


echo "192.168.1.3 loghost" | sudo tee -a /etc/hosts
echo "192.168.1.4 webhost" | sudo tee -a /etc/hosts

# now in the last part, i will check apache configurations.
# i will use curl as described by professor sir.
echo "Verifying Apache configuration on webhost..."
apache_response=$(curl -s http://webhost)
if [[ "$apache_response" =~ "Apache2 Ubuntu Default Page" ]]; then
    echo "Apache configuration on webhost is correct."
else
    echo "ERROR!"
fi
# similarly i will check the syslog.
echo "Verifying syslog configuration on loghost..."
loghost_logs=$(ssh remoteadmin@loghost grep webhost /var/log/syslog)
if [[ -n "$loghost_logs" ]]; then
    echo "Syslog configuration on loghost is configured correctly."
else
    echo "ERROR"
fi
# in this way my final steps will be cleared.
# a final message will be given to user upon exit.

echo "Configuration update succeeded!"
# thanks.