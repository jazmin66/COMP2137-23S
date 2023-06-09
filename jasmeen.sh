#!/bin/bash
# Hi sir, My name is Jasmeen Kaur and student number is 200516393
# This is linux assignment 1.
# I will be using different variables for different sections of the report.
# the first one is System Information.
# i will name the variable system_info
# i will use simple strings to show the written titles and then use the required commands which get us the required results.
system_info=$(cat <<EOF
---------------------
System Information
---------------------
Hostname: $(hostname)
OS: $(source /etc/os-release && echo $PRETTY_NAME)
Uptime: $(uptime -p)
---------------------
EOF
)

# The second section is Hardware Information.
# in this, i have lshw commands with filters which give me all the information about cpu, speed, ram, disks and video cards.
hardware_info=$(cat <<EOF
Hardware Information
---------------------
CPU: $(lscpu | grep 'Model name' | awk -F': ' '{print $2}')
Speed: $(sudo lshw -class processor | awk '/description: CPU/{p=1} p && /size:/{print $2; exit}')
MAX Speed: $(sudo lshw -class processor | awk '/description: CPU/{p=1} p && /capacity:/{print $2; exit}')
RAM: $(sudo lshw -short -C memory | grep -i 'system memory' | awk '{print $3}')
Disks: $(lsblk --output NAME,SIZE,TYPE,MOUNTPOINT,LABEL --exclude 7 | awk '!/loop/ {printf "%-8s %-8s %-4s %-8s %-7s %s\n", $1, $2, $3, $4, $5, $6}')
Video card: $(lspci -nnk | grep -i 'VGA' | awk -F': ' '{print $2}' | uniq)
---------------------
EOF
)

# next one is Network Information.
# most of the commands in this are ip commands. 
# these help me get the information about networking details like ip address, gateway, dns, etc.
network_info=$(cat <<EOF
Network Information
---------------------
FQDN: $(hostname -f)
Host Address: $(ip a show dev $(ip r | awk '/default/ {print $5}') | awk '/inet / {print $2}')
Gateway IP: $(ip r | awk '/default/ {print $3}')
DNS Server: $(grep -E '^nameserver' /etc/resolv.conf | awk '{print $2}')
Network Interface Information:
$(sudo lshw -class network | grep -E 'description|product|vendor|physical id|logical name' | awk -F ':' '{print $1 ": " $2}')
IP Address: $(ip a show dev $(ip r | awk '/default/ {print $5}') | awk '/inet / {print $2}')
---------------------
EOF
)

# The last section is of System Status.
# in this i have used basic commands which give us basic outputs. 
# but memory allocation and listening ports required more filteration to give desired results.
system_status=$(cat <<EOF
System Status
---------------------
Users Logged In: $(who | awk '{print $1}' | sort | uniq | paste -s -d ',')
Disk Space:
$(df -h)
Process Count: $(ps -e | wc -l)
Load Averages: $(uptime | awk -F'[a-z]:' '{print $2}')
Memory Allocation:
$(free -h | awk '/^Mem:/ {print "Type\tTotal\tAvailable"; print $1 "\t" $2 "\t" $7}')
Listening Network Ports:
$(ss -tuln | awk 'BEGIN {print "State\tRecv-Q\tSend-Q\tLocal Address:Port\tPeer Address:Port"} /LISTEN/ {print $1 "\t" $2 "\t" $3 "\t" $4 "\t\t" $5}')
UFW Rules: $(sudo ufw status numbered | grep -v 'Status: active')
EOF
)

# now when all sections are properly described, i will Display the information by calling the variables.
# but first of all i will print the first line which tells the report generated by user and time and date.
echo "System Report generated by $(whoami), $(date)"
echo "$system_info"
echo "$hardware_info"
echo "$network_info"
echo "$system_status"
# this is the end of file.