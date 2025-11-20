# mpima-export-toolkit
A lightweight automation toolkit that fixes the mPIMA - ALIS export workflow by setting up a working FTP proxy, validating directories, and ensuring successful export delivery in four simple steps. Designed for rapid deployment and easy use by technical teams.

<p align="center">
  <img src="https://img.shields.io/badge/mPIMA%20→%20ALIS%20Export-Automation%20Toolkit-blue?style=for-the-badge" />
</p>

<h1 align="center">mPIMA → ALIS Export Patcher</h1>

<p align="center">
  A simple 4-step automation toolkit to fix and validate the mPIMA ➜ ALIS FTP export workflow.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Status-Active-success?style=flat-square" />
  <img src="https://img.shields.io/badge/Automation-Yes-blue?style=flat-square" />
  <img src="https://img.shields.io/badge/Platform-Linux-lightgrey?style=flat-square" />
</p>

---

## 📌 Overview

The **mPIMA → ALIS Export Patcher** is a lightweight automation toolkit designed to resolve export failures between mPIMA devices and ALIS servers.  
It deploys a fully working FTP proxy, validates system paths, applies fixes, and confirms export readiness in **four simple steps**.

This tool eliminates manual troubleshooting by guiding teams through a structured and repeatable process.

---

## 🚀 Features

- ✔ Automated creation of the required FTP proxy configuration  
- ✔ Validates `/srv/mpima-export` and permissions  
- ✔ Fixes common issues with mPIMA → ALIS exports  
- ✔ Includes a diagnostic mode  
- ✔ Zero external dependencies (bash only)  
- ✔ Safe to run repeatedly  
- ✔ Ideal for field teams and rapid troubleshooting  

---

## 🔧 Requirements

- Ubuntu Server 16/18/20/22  
- sudo privileges  
- vsftpd installed (auto-checked by script)  
- Directory: `/srv/mpima-export`  
- A reachable ALIS server (if testing end-to-end)

---

## 🧭 Usage

### **Step 1 — Clone the repo**

git clone https://github.com/<your-org>/mpima-alis-export-patcher.git
cd mpima-alis-export-patcher

### **Step 2 — Make the scripts executable**
chmod +x scripts/*.sh

### **Step 3 — Run the orchestrator**
sudo ./mpima-export-patcher.sh


### **Step 4 — Follow the on-screen prompts**
The tool will guide you through:

1. Environment validation

2. Proxy setup

3. Export path and permissions check

4. Diagnostic export test
---
## 🛠 How It Works
1. Environment Check

i. Checks OS version

ii. Validates user permissions

iii. Confirms /srv/mpima-export exists

iv. Confirms vsftpd is installed and configured

2. Proxy Setup

i. Creates FTP proxy rules

ii. Ensures correct firewall rules

iii. Restarts necessary services

3. Export Validation

i. Simulates mPIMA connection

ii. Tests passive and active FTP

iii. Validates folder write/read

4. Diagnostics

i. Runs SSH, FTP, and directory tests

ii. Dumps logs into logs/

iii. Produces a final status report

## 🧪 Simulation Mode
To test without touching production:
`sudo ./mpima-export-patcher.sh --simulate`
---
##🆘 Troubleshooting
| Issue                    | Cause                  | Solution                            |
| ------------------------ | ---------------------- | ----------------------------------- |
| Export not reaching ALIS | Wrong export directory | Ensure `/srv/mpima-export` exists   |
| Connection timeout       | Proxy misconfiguration | Re-run Step 2                       |
| FTP login fails          | Wrong credentials      | Check mPIMA config and vsftpd users |
| Export stuck at 0%       | Passive mode blocked   | Script auto-opens required ports    |

---
## 🤝 Contributing
1. Fork the repository

2. Create a feature branch

3. Submit a pull request
---

## 👨‍💼 Maintainer
Benson Okello
Ministry of Health — Uganda

---
## 📜 License
MIT License
