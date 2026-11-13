#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

# ==========================================
# Server Performance Stats v2.0
# ==========================================

INTERVAL=5
CPU_THRESHOLD=80
MEM_THRESHOLD=85
DISK_THRESHOLD=90
DISK_PATH="/"
LOG_FILE=""
WATCH=false

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --watch          Enable continuous monitoring
  --interval N     Refresh interval in seconds
  --cpu N          CPU warning threshold (%)
  --memory N       Memory warning threshold (%)
  --disk N         Disk warning threshold (%)
  --path PATH      Filesystem to monitor
  --log FILE       Save metrics to a CSV file
  --help           Display this help message

Examples:
  $0
  $0 --watch --interval 5
  $0 --watch --cpu 75 --log metrics.csv
EOF
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

# ---------- Command-line arguments ----------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --watch)
            WATCH=true
            shift
            ;;
        --interval|--cpu|--memory|--disk|--path|--log)
            [[ $# -ge 2 ]] || die "Missing value for $1"

            case "$1" in
                --interval) INTERVAL="$2" ;;
                --cpu) CPU_THRESHOLD="$2" ;;
                --memory) MEM_THRESHOLD="$2" ;;
                --disk) DISK_THRESHOLD="$2" ;;
                --path) DISK_PATH="$2" ;;
                --log) LOG_FILE="$2" ;;
            esac

            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

# ---------- Validation ----------

[[ "$(uname -s)" == "Linux" ]] ||
    die "This tool requires Linux."

for cmd in awk df ps date sleep uptime; do
    command -v "$cmd" >/dev/null 2>&1 ||
        die "Required command not found: $cmd"
done

[[ "$INTERVAL" =~ ^[1-9][0-9]*$ ]] ||
    die "Interval must be a positive integer."

for threshold in "$CPU_THRESHOLD" \
                 "$MEM_THRESHOLD" \
                 "$DISK_THRESHOLD"; do
    [[ "$threshold" =~ ^(0|[1-9][0-9]{0,2})$ ]] ||
        die "Thresholds must be integers from 0 to 100."

    (( threshold <= 100 )) ||
        die "Thresholds cannot exceed 100."
done

[[ -e "$DISK_PATH" ]] ||
    die "Filesystem path does not exist."

# ---------- CPU monitoring ----------

read_cpu() {
    awk '/^cpu / {
        idle = $5 + $6
        total = 0

        for (i = 2; i <= 9; i++) {
            total += $i
        }

        print total, idle
    }' /proc/stat
}

get_cpu_usage() {
    local total1 idle1 total2 idle2
    local total_diff idle_diff

    read -r total1 idle1 < <(read_cpu)
    sleep 1
    read -r total2 idle2 < <(read_cpu)

    total_diff=$((total2 - total1))
    idle_diff=$((idle2 - idle1))

    awk -v total="$total_diff" \
        -v idle="$idle_diff" 'BEGIN {
        if (total <= 0) exit 1
        printf "%.2f", 100 * (total - idle) / total
    }'
}

# ---------- Memory monitoring ----------

get_memory_usage() {
    awk '
        /^MemTotal:/ {total = $2}
        /^MemAvailable:/ {available = $2}
        END {
            if (total <= 0 || available == "") exit 1
            printf "%.2f", 100 * (total - available) / total
        }
    ' /proc/meminfo
}

# ---------- Disk monitoring ----------

get_disk_usage() {
    df -P -- "$DISK_PATH" |
        awk 'NR == 2 {
            gsub(/%/, "", $5)
            print $5
        }'
}

# ---------- Threshold alerts ----------

check_threshold() {
    local name="$1"
    local value="$2"
    local threshold="$3"

    if awk -v v="$value" -v t="$threshold" \
        'BEGIN {exit !(v >= t)}'; then

        printf '[WARNING] %s usage: %s%% (limit: %s%%)\n' \
            "$name" "$value" "$threshold" >&2
    fi
}

# ---------- CSV logging ----------

initialise_log() {
    if [[ -n "$LOG_FILE" && ! -s "$LOG_FILE" ]]; then
        printf 'timestamp,cpu_percent,memory_percent,disk_percent\n' \
            >> "$LOG_FILE"
    fi
}

log_metrics() {
    if [[ -n "$LOG_FILE" ]]; then
        printf '%s,%s,%s,%s\n' \
            "$TIMESTAMP" \
            "$CPU_USAGE" \
            "$MEM_USAGE" \
            "$DISK_USAGE" >> "$LOG_FILE"
    fi
}

# ---------- Process monitoring ----------

show_processes() {
    printf '\nTop 5 Processes by CPU Usage\n'
    printf '%s\n' '----------------------------'

    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu |
        awk 'NR <= 6'

    printf '\nTop 5 Processes by Memory Usage\n'
    printf '%s\n' '-------------------------------'

    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem |
        awk 'NR <= 6'
}

# ---------- System information ----------

show_system_info() {
    printf '\nSystem Information\n'
    printf '%s\n' '------------------'

    printf 'Hostname: %s\n' "$(uname -n)"
    printf 'Kernel: %s\n' "$(uname -r)"
    printf 'Uptime: %s\n' "$(uptime -p)"

    printf 'Load averages: '
    awk '{print $1, $2, $3}' /proc/loadavg

    if [[ -r /etc/os-release ]]; then
        awk -F= '/^PRETTY_NAME=/ {
            gsub(/"/, "", $2)
            print "OS: " $2
        }' /etc/os-release
    fi

    if command -v who >/dev/null 2>&1; then
        printf '\nLogged-in users:\n'
        who
    fi
}

# ---------- Main monitoring cycle ----------

monitor() {
    CPU_USAGE=$(get_cpu_usage)
    MEM_USAGE=$(get_memory_usage)
    DISK_USAGE=$(get_disk_usage)
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if [[ "$WATCH" == true && -t 1 ]]; then
        printf '\033[2J\033[H'
    fi

    printf '%s\n' '========================================'
    printf '%s\n' '    SERVER PERFORMANCE STATS v2.0'
    printf '%s\n' '========================================'
    printf 'Timestamp: %s\n\n' "$TIMESTAMP"

    printf 'CPU Usage:    %s%%\n' "$CPU_USAGE"
    printf 'Memory Usage: %s%%\n' "$MEM_USAGE"
    printf 'Disk Usage:   %s%% (%s)\n' \
        "$DISK_USAGE" "$DISK_PATH"

    printf '\nThreshold Alerts\n'
    printf '%s\n' '----------------'

    check_threshold "CPU" "$CPU_USAGE" "$CPU_THRESHOLD"
    check_threshold "Memory" "$MEM_USAGE" "$MEM_THRESHOLD"
    check_threshold "Disk" "$DISK_USAGE" "$DISK_THRESHOLD"

    show_processes
    show_system_info
    log_metrics

    printf '\n%s\n' '========================================'
}

# ---------- Graceful shutdown ----------

trap 'printf "\nMonitoring stopped.\n"; exit 0' INT TERM

initialise_log

if [[ "$WATCH" == true ]]; then
    while true; do
        monitor
        sleep "$INTERVAL"
    done
else
    monitor
fi
