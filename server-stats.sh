#!/bin/bash

echo "========================================"
echo "      SERVER PERFORMANCE STATS"
echo "========================================"
echo

# -----------------------------
# CPU Usage
# -----------------------------
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

echo "CPU Usage"
echo "---------"
printf "CPU Usage: %.2f%%\n" "$CPU_USAGE"
echo

# -----------------------------
# Memory Usage
# -----------------------------
read TOTAL USED FREE <<< $(free -m | awk '/^Mem:/ {print $2, $3, $4}')

USED_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($USED/$TOTAL)*100}")
FREE_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($FREE/$TOTAL)*100}")

echo "Memory Usage"
echo "------------"
echo "Total Memory : ${TOTAL} MB"
echo "Used Memory  : ${USED} MB (${USED_PERCENT}%)"
echo "Free Memory  : ${FREE} MB (${FREE_PERCENT}%)"
echo

# -----------------------------
# Disk Usage
# -----------------------------
read DISK_TOTAL DISK_USED DISK_FREE DISK_PERCENT <<< $(df -h / | awk 'NR==2 {print $2, $3, $4, $5}')

echo "Disk Usage"
echo "----------"
echo "Total Disk : $DISK_TOTAL"
echo "Used Disk  : $DISK_USED ($DISK_PERCENT)"
echo "Free Disk  : $DISK_FREE"
echo

# -----------------------------
# Top 5 CPU Processes
# -----------------------------
echo "Top 5 Processes by CPU Usage"
echo "----------------------------"
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6
echo

# -----------------------------
# Top 5 Memory Processes
# -----------------------------
echo "Top 5 Processes by Memory Usage"
echo "-------------------------------"
ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -6
echo

# -----------------------------
# Optional Stretch Goals
# -----------------------------
echo "Additional Information"
echo "----------------------"

echo "OS Version:"
grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"'
echo

echo "System Uptime:"
uptime -p
echo

echo "Load Average:"
uptime | awk -F'load average:' '{print $2}'
echo

echo "Logged-in Users:"
who
echo

echo "========================================"