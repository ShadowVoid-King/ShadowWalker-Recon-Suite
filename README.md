# ShadowWalker – Recon Suite 🚀🔍🛡️

> **License:** Proprietary  
> **Author:** Mohamed Sayed (ShadowVoidxKing)  
> **Version:** 1.5.6  
> **Last Updated:** June 15, 2025  
> **Languages:** Bash, Python

---

**ShadowWalker** is a powerful, modular automation framework for reconnaissance and attack surface discovery. Designed for bug bounty hunters, penetration testers, and red teamers, it streamlines the entire process from subdomain enumeration to vulnerability analysis. It separates reconnaissance from active scanning, allowing for a more controlled and methodical approach to security assessments.

---

## 🆕 What's New in v1.5.6

- **Non-Root Operation**: All operations work without root access
- **Dual Implementation**: Complete Bash and Python versions
- **Enhanced Commands**: Short (-RF) and long (--recon-fast) options
- **Smart Rate Limiting**: Support for requests/second, minute, hour
- **Better Error Handling**: Detailed logging and recovery
- **Improved State Management**: Reliable session saving and recovery
- **User-Friendly**: All files in ~/.shadowwalker/
- **Cross-Platform**: Works on any Linux distribution

## 🚀 Features ⚙️✨

### 🎯 Core Features
- **Modular Phases:** Run scans in distinct stages: Recon, Discovery, Vulnerability Scanning, and Takeover Analysis.  
- **Dual Scan Modes:** Choose between a `fast` non-intrusive scan and a `deep` comprehensive scan.  
- **Automated Tool Management:** Install, update, and check all dependencies with simple commands.  
- **Permanent Environment Setup:** Automatically configures the Go environment path for globally accessible tools.

### 📊 Enhanced Capabilities
- **Smart Resource Management:**
  - Automatic system resource checking
  - Dynamic rate limiting to prevent blocking
  - Memory optimization for large scans
  - Timeout mechanisms for long-running processes

- **Advanced Output & Reporting:**
  - Multiple export formats (JSON, Markdown, HTML)
  - Visual progress tracking with progress bars
  - Detailed statistics and analysis
  - Interactive HTML reports
  
- **Improved Reliability:**
  - Resume capability for interrupted scans
  - Automatic error recovery
  - Retry mechanisms for failed operations
  - State persistence between phases

- **Enhanced Discovery:**
  - Custom wordlist generation from results
  - Advanced JavaScript analysis and endpoint extraction
  - Parallel processing for faster execution
  - Comprehensive crawling with multiple tools

### 📁 Structured Output
- Organized directory structure in `~/Hunt/TargetName/`
- Comprehensive logging in `scan.log`
- Multiple report formats:
  - Markdown summary (`_SUMMARY.md`)
  - JSON output (`results.json`)
  - HTML report (`report.html`)
  - Organized subdirectories for different artifact types

### ⚙️ Configuration Management
- JSON configuration file support
- Customizable default settings
- Profile-based scanning options
- Proxy and rate limit configuration

---

## ⚙️ Installation 🛠️📥🔧

ShadowWalker is designed for Debian-based systems like Kali Linux but can be adapted for others.

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/ShadowWalker.git
   cd ShadowWalker
   ```

2. **Make the script executable:**

   ```bash
   chmod +x ShadowWalker-Kali.bash
   ```

3. **Run the automated installer:**

   ```bash
   ./ShadowWalker-Kali.bash --install
   ```

4. **Activate the environment:**

   ```bash
   source ~/.bashrc
   # Or if you use Zsh:
   # source ~/.zshrc
   ```

---

## 🆕 Update Notice ⚠️🔄💡

This script is specifically **built to fit penetration testing distributions** like **Kali Linux** and **Parrot OS**, ensuring smooth compatibility and streamlined setup.

Additionally, it has been tested and optimized to run efficiently on **SegFault VPS** environments, making it ideal for remote or cloud-based pentesting setups.

---

## 💡 Usage & Commands 🖥️🔍📋

ShadowWalker provides a comprehensive CLI interface with smart defaults and configuration options.

### 📦 Tool Management

```bash
# Basic tool management
./ShadowWalker-Segfault.bash --check        # Check all dependencies
./ShadowWalker-Segfault.bash --install      # Install all tools
./ShadowWalker-Segfault.bash --update       # Update Go-based tools

# Configuration
./ShadowWalker-Segfault.bash --config       # Edit configuration
./ShadowWalker-Segfault.bash --reset        # Reset to defaults
```

### 🔍 Enhanced Reconnaissance

```bash
# Basic reconnaissance
./ShadowWalker-Segfault.bash --recon-fast example.com   # Quick scan
./ShadowWalker-Segfault.bash --recon-deep example.com   # Thorough scan

# With custom options
./ShadowWalker-Segfault.bash --recon-deep example.com \
    --threads 20 \
    --rate-limit "200/minute" \
    --timeout 45 \
    --output json,html
```

### 🧠 Advanced Post-Recon Modules

```bash
# Content Discovery with enhanced options
./ShadowWalker-Segfault.bash --discover example.com \
    --custom-wordlist \        # Use generated wordlist
    --js-analysis \           # Deep JS analysis
    --recursive               # Recursive discovery

# Vulnerability Scanning
./ShadowWalker-Segfault.bash --vuln-scan example.com \
    --severity high,critical \  # Filter by severity
    --categories injection,xss  # Focus categories

# Subdomain Takeover
./ShadowWalker-Segfault.bash --takeover example.com \
    --verify                   # Additional verification
```

### ⚔️ Advanced Attack Modes

```bash
# Full attack with custom configuration
./ShadowWalker-Segfault.bash --full-attack example.com \
    --config custom.json \     # Use custom config
    --output all \            # All output formats
    --notify                  # Enable notifications

# Resume interrupted scan
./ShadowWalker-Segfault.bash --resume example.com  # Auto-resume last scan
```

### 📊 Results Management

```bash
# Export results in different formats
./ShadowWalker-Segfault.bash --export example.com --format json,html

# Generate summary report
./ShadowWalker-Segfault.bash --report example.com --type full
```

### 📘 Help Menu

```bash
./ShadowWalker-Kali.bash --help
```

---

## 🛠️ Usage Guide

### Basic Commands
```bash
# Quick reconnaissance
./ShadowWalker.bash -t example.com -RF

# Deep reconnaissance with discovery
./ShadowWalker.bash -t example.com -RD -D

# Multiple operations
./ShadowWalker.bash -t example.com -RF -D -V

# With custom parameters
./ShadowWalker.bash -t example.com -RF -T 20 -tO 45
```

### Progress Management
```bash
# Resume interrupted scan
./ShadowWalker.bash -RP

# List progress points
./ShadowWalker.bash -LP example.com
```

### Command Reference
```bash
Commands:
  -RF, --recon-fast      Fast reconnaissance scan
  -RD, --recon-deep      Deep reconnaissance scan
  -D,  --discover        Active discovery scan
  -V,  --vuln-scan      Vulnerability scan
  -RP, --resume-progress Resume last interrupted scan
  -LP, --list-progress   List saved progress points

Parameters:
  -t,  --target         Target domain
  -T,  --threads        Number of threads (default: 10)
  -tO, --timeout        Timeout in seconds (default: 30)
  -i,  --input          Input file with targets/domains
  -o,  --output         Custom output directory
```

---

## 🎯 Command Reference

### Scan Commands and Tools
| Command | Description | Tools Used |
|---------|-------------|------------|
| -RF, --recon-fast | Quick reconnaissance scan | - subfinder (passive subdomain enum)<br>- findomain (cert transparency)<br>- assetfinder (asset discovery)<br>- httpx (host probing) |
| -RD, --recon-deep | Deep reconnaissance scan | - amass (extensive enumeration)<br>- dnsgen (permutation scanning)<br>- puredns (resolver)<br>- subfinder & findomain<br>- massdns (resolution) |
| -D, --dns | DNS enumeration scan | - dnsx (DNS toolkit)<br>- amass (DNS enum mode)<br>- puredns (validation)<br>- massdns (record enum) |
| -V, --vuln | Vulnerability scan | - nuclei (vuln scanner)<br>- httpx (tech detection)<br>- katana (crawler)<br>- gf-patterns (pattern matching) |

### Scan Control
| Short Form | Long Form | Default | Description |
|------------|-----------|---------|-------------|
| -T | --threads | 10 | Number of threads |
| -O | --timeout | 30 | Timeout in seconds |
| -R | --rate | 150/minute | Rate limit for requests |
| -f | --format | json | Output format (json/markdown/html) |

### Progress & Recovery
| Short Form | Long Form | Description |
|------------|-----------|-------------|
| -RP | --resume | Resume last interrupted scan |
| -LP | --list-progress | List available recovery points |
| -s | --save | Save progress point |

### Examples
```bash
# Basic reconnaissance
./ShadowWalker.bash -t example.com -RF
./ShadowWalker.py -t example.com -RF

# Deep scan with custom parameters
./ShadowWalker.bash -t example.com -RD -T 20 -O 45
./ShadowWalker.py -t example.com --recon-deep --threads 20 --timeout 45

# Multiple operations
./ShadowWalker.bash -t example.com -RF -D -V
./ShadowWalker.py -t example.com --recon-fast --dns --vuln

# Rate-limited vulnerability scan
./ShadowWalker.bash -t example.com -V -R 200/minute
./ShadowWalker.py -t example.com --vuln --rate "200/minute"
```

### Output Directory Structure
```
~/Hunt/
└── example.com/
    ├── recon/
    │   ├── subdomains.txt
    │   ├── wildcards.txt
    │   └── resolved.txt
    ├── discovery/
    │   ├── paths.txt
    │   ├── endpoints.txt
    │   └── parameters.txt
    ├── vulnerabilities/
    │   ├── findings.json
    │   └── reports/
    └── logs/
        └── scan.log
```

### Configuration
- All configuration files are stored in `~/.shadowwalker/`
- No root access required for any operations
- Automatically adapts to available system resources
- Supports both Bash and Python implementations

---

## 📚 Recommended Workflow 🗂️🔎🛠️

1. **Start with deep recon:**

   ```bash
   ./ShadowWalker-Kali.bash --recon-deep target.com
   ```

2. **Analyze recon results in the generated directories.**

3. **Run discovery phase:**

   ```bash
   ./ShadowWalker-Kali.bash --discover target.com
   ```

4. **In another terminal, scan for vulnerabilities:**

   ```bash
   ./ShadowWalker-Kali.bash --vuln-scan target.com
   ```

5. **Check for subdomain takeover:**

   ```bash
   ./ShadowWalker-Kali.bash --takeover target.com
   ```

6. **Review output files for insights.**

---

## ⚙️ Configuration File

ShadowWalker now supports a configuration file located at `~/.config/shadowwalker/config.json`:

```json
{
    "threads": 10,
    "timeout": 30,
    "rate_limit": "150/minute",
    "output_format": "markdown",
    "auto_resume": true,
    "notification_webhook": "",
    "proxy": "",
    "excluded_tools": []
}
```

## 📂 Enhanced Output Structure

```plaintext
~/Hunt/
└── example.com/
    ├── scan.log              # Detailed scan log
    ├── _SUMMARY.md          # Markdown summary
    ├── results.json         # JSON format results
    ├── report.html          # HTML report
    ├── endpoints/           # Discovered endpoints
    │   ├── katana_endpoints.txt
    │   ├── gospider_endpoints.txt
    │   └── js_endpoints.txt
    ├── js_files/           # JavaScript analysis
    │   ├── all_js_files.txt
    │   └── js_secrets.txt
    ├── parameters/         # Discovered parameters
    ├── wordlists/         # Custom generated wordlists
    │   ├── custom_paths.txt
    │   └── custom_params.txt
    ├── passive_subs.txt   # Passive enumeration results
    ├── perm_subs.txt      # Permutation results
    ├── all_subs.txt       # Combined subdomains
    ├── resolved.txt       # Resolved subdomains
    └── live_hosts.txt     # Live web servers
```

## 🔄 Resume Capability

ShadowWalker now includes automatic scan resumption:
- Progress is saved in `/tmp/shadowwalker_resume.json`
- Automatically recovers from interruptions
- Maintains state between different scan phases
- Smart checkpoint system for long-running operations

---

## ⚡ Latest Features

### 🎮 Command Shortcuts
- `-RF` for quick recon
- `-RD` for deep recon
- `-D` for discovery
- `-V` for vulnerability scan
- `-RP` to resume progress
- `-LP` to list progress points

### ⚙️ Scan Control
- Thread control with `-T` or `--threads`
- Timeout control with `-O` or `--timeout`
- Rate limiting with `-r` or `--rate-limit`
- Safe defaults and validation
- Automatic error recovery

### 📊 Progress Management
- Auto-save on interruption
- Progress recovery system
- Multiple save points
- Session management
- State preservation

### 📝 Logging System
- System-wide error logging
- Target-specific logs
- Performance tracking
- Tool status monitoring
- Detailed error reports

### 🛠️ Tool Integration
- Automatic dependency checking
- Version verification
- Update management
- Configuration persistence
- Environment detection

## 📋 Quick Reference

### Basic Usage
```bash
# Quick scan
./ShadowWalker.bash -t example.com -RF

# Deep scan with parameters
./ShadowWalker.bash -t example.com -RD -T 20 -O 45

# Multiple operations
./ShadowWalker.bash -t example.com -RF -D -V
```

### Progress Management
```bash
# Resume last scan
./ShadowWalker.bash -RP

# List progress points
./ShadowWalker.bash -LP example.com
```

### Directory Structure
```
~/Hunt/<domain>/
├── recon/          # Reconnaissance results
├── discovery/      # Discovery scan results
├── vulns/          # Vulnerability scan results
└── logs/          # Target-specific logs

/var/log/shadowwalker/
├── errors/        # System-wide error logs
├── tools/         # Tool execution logs
└── performance/   # Performance metrics
```

---

## 🛡️ License & Legal Notice 📜⚖️🚫

**ShadowWalker v0.7 - Proprietary License**  
Copyright (c) 2025 Mohamed Sayed  
aka **ShadowVoidxKing**

All rights reserved.

This software, including the **idea, name, structure, modules, scripts, workflows, reporting format, and source code**, is the **intellectual property** of the author.

You are granted a **limited, non-exclusive right** to:

- Use this tool for **educational or legally authorized security assessments**.  
- Participate in **bug bounty**, **red teaming**, or **personal labs** with permission.

---

### ❌ You Are NOT Allowed To:

- Fork, copy, redistribute, or modify this repository.  
- Create derivative tools or frameworks based on ShadowWalker.  
- Use the name "ShadowWalker", "ShadowVoidxKing", or anything similar.  
- Include this in **commercial products or services**.  
- Use it against systems **you do not own or lack permission to test**.

---

### ⚠️ Legal Use Only

You, the user, are **solely responsible** for your actions.  
The author is **not responsible** for:

- Illegal activity  
- System misuse  
- Any resulting damage

---

## 📮 Permission Requests ✉️🤝🔑

To:

- Contribute, adapt, or integrate ShadowWalker,  
- Use it in a larger system or product,  
- Translate or license it,  

You **must** request permission by:

- Opening a GitHub Issue, **OR**  
- Contacting the author through GitHub.

---

📄 See: [LICENSE.txt](./LICENSE.txt)

This project is licensed under a **Proprietary License**.  
Please refer to the full terms in the [LICENSE.txt](./LICENSE.txt) file.

---

## 🛠️ Tools Used in Each Mode

### 🔍 Fast Recon Mode (-RF)
Fast reconnaissance focuses on quick, passive enumeration:
- **subfinder**: Passive subdomain discovery using various sources
- **findomain**: Certificate transparency log enumeration
- **assetfinder**: Asset discovery through various sources
- **httpx**: Fast web server probing and technology detection

### 🔬 Deep Recon Mode (-RD)
Deep reconnaissance performs thorough enumeration:
- **amass**: Comprehensive attack surface mapping
- **dnsgen**: Smart DNS permutation generation
- **puredns**: Fast DNS resolution with validation
- **subfinder & findomain**: Multiple source enumeration
- **massdns**: High-performance DNS resolution

### 🌐 DNS Enumeration Mode (-D)
DNS enumeration focuses on DNS record discovery:
- **dnsx**: Advanced DNS toolkit and validator
- **amass**: DNS enumeration specific mode
- **puredns**: DNS validation and resolution
- **massdns**: Comprehensive DNS record enumeration

### 🎯 Vulnerability Scan Mode (-V)
Vulnerability scanning with multiple tools:
- **nuclei**: Template-based vulnerability scanner
- **httpx**: HTTP server fingerprinting
- **katana**: Smart web crawling and endpoint discovery
- **gf-patterns**: Pattern matching for vulnerabilities

### 📊 Output Processing
All modes include:
- Automatic result filtering
- Duplicate removal
- False positive elimination
- Live host validation
- Structured output organization

### 🔄 Tool Requirements
```bash
# Core tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# Additional tools
go install -v github.com/OWASP/Amass/v3/...@master
go install -v github.com/tomnomnom/assetfinder@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest

# Helper tools
go install -v github.com/tomnomnom/gf@latest
python3 -m pip install dnsgen
```