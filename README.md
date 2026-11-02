https://roadmap.sh/projects/server-stats


# 🖥️ Server Performance Stats

A lightweight **Linux Server Monitoring Tool** built using Bash that provides insights into system resource utilisation and performance.

The script collects and displays key system metrics, including CPU usage, memory consumption, disk utilisation, and resource-intensive processes.

Inspired by the [roadmap.sh Server Stats Project](https://roadmap.sh/projects/server-stats).

---

## 🚀 Features

### 1. CPU Monitoring
- Retrieves current CPU utilisation.
- Calculates CPU usage as a percentage.
- Displays CPU consumption in a readable format.

### 2. Memory Monitoring
- Retrieves total, used and available system memory.
- Calculates memory utilisation percentages.
- Displays memory statistics in MB.

### 3. Disk Monitoring
- Retrieves total disk capacity.
- Calculates used and available storage.
- Displays disk utilisation as a percentage.

### 4. Process Monitoring
- Identifies the top 5 processes by CPU consumption.
- Identifies the top 5 processes by memory consumption.
- Displays process IDs, usernames and resource utilisation.

### 5. Additional System Information
- Operating system version.
- System uptime.
- System load averages.
- Currently logged-in users.

---

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Bash | Automation and scripting |
| Linux | Operating system environment |
| `top` | CPU utilisation monitoring |
| `free` | Memory statistics |
| `df` | Disk utilisation |
| `ps` | Process monitoring |
| `awk` | Data extraction and calculations |
| `grep` | Filtering system information |

---

## 📂 Project Structure

```text
Server-Performance-Stats/
│
├── server-stats.sh
│
└── README.md
```

---

## ⚙️ Installation & Usage

### Prerequisites

- Linux-based operating system.
- Bash shell.
- Standard Linux utilities: `top`, `free`, `df`, `ps`, `awk`, `grep`, `uptime` and `who`.

### 1. Clone the repository

```bash
git clone https://github.com/DarshKParikh/Server-Performance-Stats.git
```

### 2. Navigate into the project

```bash
cd Server-Performance-Stats
```

### 3. Make the script executable

```bash
chmod +x server-stats.sh
```

### 4. Run the monitoring tool

```bash
./server-stats.sh
```

The script automatically collects system information and displays the results in your terminal.

---

## 📊 Example Output

```text
========================================
 SERVER PERFORMANCE STATS
========================================

CPU Usage
---------
CPU Usage: XX.XX%

Memory Usage
------------
Total Memory : XXXX MB
Used Memory  : XXXX MB (XX.XX%)
Free Memory  : XXXX MB (XX.XX%)

Disk Usage
----------
Total Disk : XXG
Used Disk  : XXG (XX%)
Free Disk  : XXG

Top 5 Processes by CPU Usage
----------------------------
PID    USER    %CPU    %MEM    COMMAND

Top 5 Processes by Memory Usage
-------------------------------
PID    USER    %CPU    %MEM    COMMAND

Additional Information
----------------------
OS Version:
Linux Distribution

System Uptime:
Up X hours

Load Average:
System load information

Logged-in Users:
Current users
```

*Note: Values will vary depending on the machine running the script.*

---

## 🧠 Key Concepts & Learning Outcomes

Developing this project strengthened my understanding of:

- **Linux System Administration:** Interacting with Linux system utilities to retrieve hardware and operating system information.
- **Shell Scripting:** Automating repetitive system monitoring tasks using Bash.
- **Process Management:** Analysing running processes and identifying resource-intensive applications.
- **Data Processing:** Extracting, filtering and manipulating command-line output using tools such as `awk` and `grep`.
- **Performance Monitoring:** Understanding CPU utilisation, memory consumption, disk capacity and system load averages.
- **Automation:** Combining multiple Linux utilities into a single executable monitoring tool.

---

## 🔮 Future Improvements

- [ ] Add configurable CPU, memory and disk usage warning thresholds.
- [ ] Implement continuous monitoring with configurable refresh intervals.
- [ ] Introduce historical performance logging.
- [ ] Export performance reports to CSV.
- [ ] Add automated alerts when resource utilisation exceeds defined thresholds.
- [ ] Support monitoring multiple machines remotely.

---

## 👨‍💻 Author

**Darsh Parikh**

[GitHub Profile](https://github.com/DarshKParikh)

---

*Built to explore Linux system administration, Bash scripting and computer performance monitoring.*

