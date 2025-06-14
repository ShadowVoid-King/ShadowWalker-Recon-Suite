# ShadowWalker – Recon Suite 🚀🔍🛡️

> **License:** Proprietary  
> **Author:** Mohamed Sayed (ShadowVoidxKing)  
> **Version:** 0.7  
> **Last Updated:** June 14, 2025

---

**ShadowWalker** is a powerful, modular automation framework for reconnaissance and attack surface discovery. Designed for bug bounty hunters, penetration testers, and red teamers, it streamlines the entire process from subdomain enumeration to vulnerability analysis. It separates reconnaissance from active scanning, allowing for a more controlled and methodical approach to security assessments.

---

## 🚀 Features ⚙️✨

- **Modular Phases:** Run scans in distinct stages: Recon, Discovery, Vulnerability Scanning, and Takeover Analysis.  
- **Dual Scan Modes:** Choose between a `fast` non-intrusive scan and a `deep` comprehensive scan.  
- **Automated Tool Management:** Install, update, and check all dependencies with simple commands.  
- **Permanent Environment Setup:** Automatically configures the Go environment path for globally accessible tools.  
- **Structured Output:** Saves results for each target in a clean, organized `~/Hunt/TargetName/` directory.  
- **Comprehensive Logging:** Creates a detailed `scan.log` for each target, recording all actions, results, file sizes, and errors.  
- **Markdown Reporting:** Generates a `_SUMMARY.md` report that is updated after each phase.

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

You can run the script with CLI flags or interactively.

### 📦 Tool Management

```bash
./ShadowWalker-Kali.bash --check        # Check all dependencies
./ShadowWalker-Kali.bash --install      # Install all tools
./ShadowWalker-Kali.bash --update       # Update Go-based tools
```

### 🔍 Reconnaissance

```bash
./ShadowWalker-Kali.bash --recon-fast example.com
./ShadowWalker-Kali.bash --recon-deep example.com
```

> Output will be saved to: `~/Hunt/example.com/`

### 🧠 Post-Recon Modules

```bash
./ShadowWalker-Kali.bash --discover example.com     # Content Discovery
./ShadowWalker-Kali.bash --vuln-scan example.com    # Vulnerability Scanning
./ShadowWalker-Kali.bash --takeover example.com     # Subdomain Takeover
```

### ⚔️ Full Attack Mode

```bash
./ShadowWalker-Kali.bash --full-attack example.com
```

### 📘 Help Menu

```bash
./ShadowWalker-Kali.bash --help
```

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