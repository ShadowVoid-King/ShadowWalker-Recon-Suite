#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# |                 ShadowWalker Recon Script (Segfault Edition v0.7)         |
# -----------------------------------------------------------------------------
# | Description:                                                            |
# |   Professional, modular recon framework for custom VPS environments.    |
# |   Manages dependencies, sets up the Go env, and provides detailed logs. |
# |                                                                         |
# | Author:                                                                 |
# |   ShadowVoidxKing                                                       |
# -----------------------------------------------------------------------------

# --- Configuration ---
PERM_WORDLIST="/opt/SecLists/Discovery/DNS/dns-jhaddix.txt"
GOBUSTER_WORDLIST="/opt/SecLists/Discovery/DNS/subdomains-top1million-110000.txt"
FFUF_WORDLIST="/opt/SecLists/Discovery/Web-Content/common.txt"
DIRSEARCH_WORDLIST="/opt/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt"
RESOLVERS_LIST="$HOME/lists/resolvers.txt"
HUNT_DIR="$HOME/Hunt"

# --- Colors ---
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; CYAN="\e[36m"; NC="\e[0m"

# --- Tool List (for checking) ---
REQUIRED_TOOLS=(subfinder findomain jq httpx dnsgen puredns gobuster waybackurls ffuf nuclei arjun dirsearch gospider katana jsluice kr subzy go git python3 pip)
LOG_FILE="" # Global log file variable

################################################################################
#                                  FUNCTIONS                                   #
################################################################################

display_banner() { clear; echo -e "${CYAN}"; echo "███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗██╗    ██╗ █████╗ ██╗     ██╗  ██╗███████╗██████╗ "; echo "██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║██║    ██║██╔══██╗██║     ██║ ██╔╝██╔════╝██╔══██╗"; echo "███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║██║ █╗ ██║███████║██║     █████╔╝ █████╗  ██████╔╝"; echo "╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║██║███╗██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗"; echo "███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝╚███╔███╔╝██║  ██║███████╗██║  ██╗███████╗██║  ██║"; echo "╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"; echo -e "${NC}"; printf "%*s\n" $(( ($(tput cols) + 21) / 2 )) "v0.7 by ShadowVoidxKing"; echo ""; }
display_help() { display_banner; echo "ShadowWalker v0.7 - Modular Recon & Attack Framework"; echo "----------------------------------------------------"; echo "Usage: $0 [mode] [target]"; echo ""; echo -e "${CYAN}CORE COMMANDS:${NC}"; echo "  --recon-fast <domain>    Runs fast subdomain enumeration."; echo "  --recon-deep <domain>    Runs comprehensive subdomain enumeration."; echo "  --full-attack <domain>   Runs all phases sequentially (recon-deep, discover, vuln-scan, takeover)."; echo ""; echo -e "${CYAN}POST-RECON MODULES (target is the domain name):${NC}"; echo "  --discover <domain>      Runs content discovery on a completed recon target."; echo "  --vuln-scan <domain>     Runs vulnerability analysis on a completed recon target."; echo "  --takeover <domain>      Checks for subdomain takeovers on a completed recon target."; echo ""; echo -e "${CYAN}TOOL MANAGEMENT:${NC}"; echo "  --install                Install or re-install all required tools."; echo "  --update                 Update all Go-based tools."; echo "  --check                  Check if all required tools are installed."; echo "  -h, --help               Display this help menu."; echo ""; }

# --- Logging & Utility Functions ---
log_event() { local type="$1"; local message="$2"; local timestamp; timestamp=$(date '+%Y-%m-%d %H:%M:%S'); echo "[$timestamp] [$type] $message" >> "$LOG_FILE"; }
log_file_size() { local file_path="$1"; if [ -f "$file_path" ]; then local bytes; bytes=$(stat -c%s "$file_path"); local mbytes; mbytes=$(awk "BEGIN {printf \"%.2f\", $bytes / 1024 / 1024}"); log_event "RESULT" "Created '$file_path' ($bytes bytes / $mbytes MB)."; fi; }
msg() { echo -e "${BLUE}[*]${NC} ${1}"; log_event "INFO" "${1}"; }
success() { echo -e "${GREEN}[+]${NC} ${1}"; log_event "SUCCESS" "${1}"; }
warn() { echo -e "${YELLOW}[!]${NC} ${1}"; log_event "WARN" "${1}"; }
error() { echo -e "${RED}[-]${NC} ${1}" >&2; log_event "ERROR" "${1}"; }

# --- Tool Management ---
setup_go_env() { msg "Configuring Go environment..."; GOPATH_BIN=$(go env GOPATH)/bin; SHELL_CONFIG=""; if [ -n "$BASH_VERSION" ]; then SHELL_CONFIG="$HOME/.bashrc"; elif [ -n "$ZSH_VERSION" ]; then SHELL_CONFIG="$HOME/.zshrc"; fi; if [ -z "$SHELL_CONFIG" ]; then warn "Could not determine shell. Please add '$GOPATH_BIN' to your PATH manually."; return; fi; if ! grep -q "GOPATH/bin" "$SHELL_CONFIG"; then warn "Go binary path not found in PATH. Adding it to $SHELL_CONFIG."; echo -e "\n# GoLang Path\nexport PATH=\$PATH:$GOPATH_BIN" >> "$SHELL_CONFIG"; success "Go path added. Please run 'source $SHELL_CONFIG' or open a new terminal."; else success "Go environment path is already configured."; fi; }
install_tools() { msg "Installing system dependencies..."; sudo apt update && sudo apt install -y git subfinder findomain jq gobuster golang-go ffuf python3-pip; setup_go_env; msg "Installing Python tools..."; cat > requirements.txt << EOF; arjun; dirsearch; EOF; pip3 install --user -r requirements.txt; rm requirements.txt; msg "Installing Go tools..."; cat > go_tools.txt << EOF; github.com/projectdiscovery/httpx/cmd/httpx@latest; github.com/d3mondev/puredns/v2@latest; github.com/projectdiscovery/waybackurls/cmd/waybackurls@latest; github.com/projectdiscovery/dnsgen/cmd/dnsgen@latest; github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest; github.com/projectdiscovery/katana/cmd/katana@latest; github.com/hakluke/gospider@latest; github.com/fifty-six/jsluice/cmd/jsluice@latest; github.com/assetnote/kiterunner/cmd/kr@latest; github.com/LukaSikic/subzy@latest; EOF; while read -r tool; do go install -v "$tool"; done < go_tools.txt; rm go_tools.txt; msg "Downloading wordlists..."; [ ! -d "/opt/SecLists" ] && sudo git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists; mkdir -p "$HOME/lists" && wget -O "$HOME/lists/resolvers.txt" https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt; success "Installation complete."; warn "Please restart your terminal or run 'source ~/.bashrc' (or .zshrc)."; }
update_tools() { msg "Updating Go tools..."; while read -r tool; do go install -v "$tool"; done < <(cat <<EOF; github.com/projectdiscovery/httpx/cmd/httpx@latest; github.com/d3mondev/puredns/v2@latest; github.com/projectdiscovery/waybackurls/cmd/waybackurls@latest; github.com/projectdiscovery/dnsgen/cmd/dnsgen@latest; github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest; github.com/projectdiscovery/katana/cmd/katana@latest; github.com/hakluke/gospider@latest; github.com/fifty-six/jsluice/cmd/jsluice@latest; github.com/assetnote/kiterunner/cmd/kr@latest; github.com/LukaSikic/subzy@latest; EOF); success "Update complete."; }
check_tools() { msg "Checking tools..."; all_found=true; for tool in "${REQUIRED_TOOLS[@]}"; do if ! command -v "$tool" &> /dev/null; then error "MISSING: $tool"; all_found=false; else success "FOUND: $tool"; fi; done; if [ "$all_found" = true ]; then success "All tools are installed."; else warn "Some tools are missing. Run --install"; fi; }

# --- Core Scan Phases ---
run_recon() {
    local domain=$1; local mode=$2; local output_dir="$HUNT_DIR/$domain"; mkdir -p "$output_dir"; LOG_FILE="$output_dir/scan.log"; cd "$output_dir" || exit 1
    display_banner; msg "Starting RECON ($mode) for: ${YELLOW}$domain${NC}"; msg "Output directory: $output_dir"
    
    msg "Enumerating subdomains..."; 
    if [ "$mode" == "recon-deep" ]; then
        { subfinder -all -silent -d "$domain"; findomain --quiet -t "$domain"; curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g'; gobuster dns -d "$domain" -w "$GOBUSTER_WORDLIST" -q | awk '{print $2}'; } | sort -u > "passive_subs.txt" 2>> "$LOG_FILE"
        log_file_size "passive_subs.txt"
        msg "Generating permutations..."; dnsgen "passive_subs.txt" -w "$PERM_WORDLIST" > "perm_subs.txt" 2>> "$LOG_FILE"; log_file_size "perm_subs.txt"
        cat "passive_subs.txt" "perm_subs.txt" | sort -u > "all_subs.txt"; log_file_size "all_subs.txt"
    else
        { subfinder -all -silent -d "$domain"; findomain --quiet -t "$domain"; } | sort -u > "all_subs.txt" 2>> "$LOG_FILE"; log_file_size "all_subs.txt"
    fi
    msg "Resolving subdomains..."; puredns resolve "all_subs.txt" -r "$RESOLVERS_LIST" -w "resolved.txt" -q 2>> "$LOG_FILE"; log_file_size "resolved.txt"
    msg "Probing for live web servers..."; httpx -l "resolved.txt" -silent -sc -title -tech-detect -ip -cdn -o "live_hosts.txt" 2>> "$LOG_FILE"; log_file_size "live_hosts.txt"
    
    echo "# ShadowWalker Recon Summary: $domain" > _SUMMARY.md
    echo "**Mode:** \`$mode\`" >> _SUMMARY.md; echo "**Time:** \`$(date)\`" >> _SUMMARY.md; echo "" >> _SUMMARY.md
    echo "## Reconnaissance" >> _SUMMARY.md
    echo "| Phase | Count |" >> _SUMMARY.md; echo "|---|---|" >> _SUMMARY.md
    echo "| Potential Subdomains | $(wc -l < all_subs.txt) |" >> _SUMMARY.md; echo "| Resolved Subdomains | $(wc -l < resolved.txt) |" >> _SUMMARY.md; echo "| Live Web Hosts | $(wc -l < live_hosts.txt) |" >> _SUMMARY.md; echo "" >> _SUMMARY.md
    success "Recon complete. Results are in: ${GREEN}$(pwd)${NC}"
}

run_discover() {
    local domain=$1; local scan_dir="$HUNT_DIR/$domain"; [ ! -d "$scan_dir" ] && { error "Scan directory for $domain not found. Run recon first."; exit 1; }; cd "$scan_dir" || exit 1; LOG_FILE="$scan_dir/scan.log"
    display_banner; msg "Starting DISCOVERY phase for: ${YELLOW}$domain${NC}"; [ ! -f "live_hosts.txt" ] && { error "live_hosts.txt not found. Please run a recon scan first."; exit 1; }
    
    msg "Crawling with Katana & Gospider..."; 
    katana -l live_hosts.txt -silent -o katana_endpoints.txt 2>> "$LOG_FILE"; log_file_size "katana_endpoints.txt"
    gospider -S live_hosts.txt -o gospider_output -c 10 -d 5 --other-source --include-subs 2>> "$LOG_FILE";
    
    msg "Brute-forcing directories with FFUF & Dirsearch...";
    ffuf -w "$FFUF_WORDLIST" -l live_hosts.txt -mc 200,204,301,302,307,401,403 -o ffuf_results.json 2>> "$LOG_FILE"; log_file_size "ffuf_results.json"
    dirsearch -l live_hosts.txt -w "$DIRSEARCH_WORDLIST" --simple-report -o dirsearch_results.txt 2>> "$LOG_FILE"; log_file_size "dirsearch_results.txt"
    
    echo -e "\n## Content Discovery" >> _SUMMARY.md; echo "| Tool | Output File |" >> _SUMMARY.md; echo "|---|---|" >> _SUMMARY.md; echo "| Katana | \`katana_endpoints.txt\` |" >> _SUMMARY.md; echo "| Gospider | \`gospider_output/\` |" >> _SUMMARY.md; echo "| FFUF | \`ffuf_results.json\` |" >> _SUMMARY.md; echo "| Dirsearch | \`dirsearch_results.txt\` |" >> _SUMMARY.md; echo "" >> _SUMMARY.md
    success "Discovery complete."
}

run_vuln_scan() {
    local domain=$1; local scan_dir="$HUNT_DIR/$domain"; [ ! -d "$scan_dir" ] && { error "Scan directory for $domain not found."; exit 1; }; cd "$scan_dir" || exit 1; LOG_FILE="$scan_dir/scan.log"
    display_banner; msg "Starting VULNERABILITY SCAN phase for: ${YELLOW}$domain${NC}"; [ ! -f "live_hosts.txt" ] && { error "live_hosts.txt not found."; exit 1; }
    
    msg "Scanning for vulnerabilities with Nuclei..."; nuclei -l live_hosts.txt -t cves,misconfiguration,technologies,takeovers,vulnerabilities -o nuclei_vulns.txt 2>> "$LOG_FILE"; log_file_size "nuclei_vulns.txt"
    msg "Analyzing JavaScript files with JSLuice..."; cat live_hosts.txt | httpx -silent -path / | getJS > jsluice_secrets.txt 2>> "$LOG_FILE"; log_file_size "jsluice_secrets.txt"
    msg "Hunting for API endpoints with Kiterunner..."; kr scan -L live_hosts.txt -w "$FFUF_WORDLIST" -A=apis -o kiterunner_apis.txt 2>> "$LOG_FILE"; log_file_size "kiterunner_apis.txt"
    msg "Fuzzing for parameters with Arjun..."; arjun -i live_hosts.txt -oT arjun_params.txt 2>> "$LOG_FILE"; log_file_size "arjun_params.txt"
    
    echo -e "\n## Vulnerability & Analysis" >> _SUMMARY.md; echo "| Tool | Output File |" >> _SUMMARY.md; echo "|---|---|" >> _SUMMARY.md; echo "| Nuclei | \`nuclei_vulns.txt\` |" >> _SUMMARY.md; echo "| JSLuice | \`jsluice_secrets.txt\` |" >> _SUMMARY.md; echo "| Kiterunner | \`kiterunner_apis.txt\` |" >> _SUMMARY.md; echo "| Arjun | \`arjun_params.txt\` |" >> _SUMMARY.md; echo "" >> _SUMMARY.md
    success "Vulnerability scan complete."
}

run_takeover_check() {
    local domain=$1; local scan_dir="$HUNT_DIR/$domain"; [ ! -d "$scan_dir" ] && { error "Scan directory for $domain not found."; exit 1; }; cd "$scan_dir" || exit 1; LOG_FILE="$scan_dir/scan.log"
    display_banner; msg "Checking for SUBDOMAIN TAKEOVERS for: ${YELLOW}$domain${NC}"; [ ! -f "resolved.txt" ] && { error "resolved.txt not found."; exit 1; }
    
    msg "Running Subzy..."; subzy run --targets resolved.txt --output subzy_takeovers.txt 2>> "$LOG_FILE"; log_file_size "subzy_takeovers.txt"
    
    echo -e "\n## Subdomain Takeover" >> _SUMMARY.md; local takeover_count; takeover_count=$(wc -l < subzy_takeovers.txt); echo "Found **$takeover_count** potential takeovers. Check \`subzy_takeovers.txt\` for details." >> _SUMMARY.md; echo "" >> _SUMMARY.md
    success "Takeover check complete."
}

# --- Script Start ---
if [ "$#" -gt 0 ]; then
    case $1 in
        --recon-fast) [ -z "$2" ] && { error "Usage: $0 --recon-fast <domain>"; exit 1; }; run_recon "$2" "recon-fast" ;;
        --recon-deep) [ -z "$2" ] && { error "Usage: $0 --recon-deep <domain>"; exit 1; }; run_recon "$2" "recon-deep" ;;
        --discover) [ -z "$2" ] && { error "Usage: $0 --discover <domain>"; exit 1; }; run_discover "$2" ;;
        --vuln-scan) [ -z "$2" ] && { error "Usage: $0 --vuln-scan <domain>"; exit 1; }; run_vuln_scan "$2" ;;
        --takeover) [ -z "$2" ] && { error "Usage: $0 --takeover <domain>"; exit 1; }; run_takeover_check "$2" ;;
        --full-attack) [ -z "$2" ] && { error "Usage: $0 --full-attack <domain>"; exit 1; }; run_recon "$2" "recon-deep"; run_discover "$2"; run_vuln_scan "$2"; run_takeover_check "$2" ;;
        --install) install_tools ;;
        --update) update_tools ;;
        --check) check_tools ;;
        -h|--help) display_help ;;
        *) error "Invalid flag: $1."; display_help ; exit 1 ;;
    esac
    exit 0
fi
display_help
