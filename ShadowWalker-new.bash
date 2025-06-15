#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# |                 ShadowWalker Universal Recon Suite v1.4.5                 |
# -----------------------------------------------------------------------------
# | Description:                                                              |
# |   Universal reconnaissance framework for all pentesting environments.     |
# |   Combined features from Segfault and Kali editions with enhanced        |
# |   recovery system and environment detection.                             |
# |                                                                          |
# | Author: Mohamed Sayed (ShadowVoidxKing)                                  |
# | Updated: June 15, 2025                                                   |
# -----------------------------------------------------------------------------

# --- Color Definitions ---
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
PURPLE="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
NC="\e[0m"
BOLD_RED="\e[1;31m"
BOLD_GREEN="\e[1;32m"
BOLD_YELLOW="\e[1;33m"
BOLD_BLUE="\e[1;34m"
BOLD_PURPLE="\e[1;35m"
BOLD_CYAN="\e[1;36m"
BOLD_WHITE="\e[1;37m"

# --- Global Variables ---
VERSION="1.4.5"
BUILD_DATE="2025-06-15"
CODENAME="StableHunter"

# --- Directory Structure ---
HOME_DIR="$HOME/.shadowwalker"
LOG_DIR="$HOME_DIR/logs"
CONFIG_DIR="$HOME_DIR/config"
RECOVERY_DIR="$HOME_DIR/recovery"
PROGRESS_DIR="$HOME_DIR/progress"
HUNT_DIR="$HOME/Hunt"

# --- Configuration Files ---
CONFIG_FILE="$CONFIG_DIR/config.json"
SESSION_FILE="$RECOVERY_DIR/current_session.json"
RESUME_FILE="$PROGRESS_DIR/resume.json"

# --- Default Settings ---
DEFAULT_THREADS=10
DEFAULT_TIMEOUT=30
DEFAULT_RATE_LIMIT="150/minute"
DEFAULT_OUTPUT_FORMAT="json"
DEFAULT_COMMAND="recon_fast"
DEFAULT_TARGET=""

# --- Limits ---
MAX_THREADS=50
MIN_TIMEOUT=5
MAX_RATE="300/minute"

# --- Output Formats ---
OUTPUT_FORMATS=("json" "markdown" "html")

# --- Tool Requirements ---
REQUIRED_TOOLS=(
    subfinder findomain jq httpx dnsgen puredns gobuster 
    waybackurls ffuf nuclei arjun dirsearch gospider 
    katana jsluice kr subzy go git python3 pip bbot
)

# --- Helper Functions ---
reset_color() {
    echo -en "${NC}"
}

log_info() {
    echo -e "${BOLD_CYAN}[+]${NC} $1"
    reset_color
}

log_success() {
    echo -e "${BOLD_GREEN}[✓]${NC} $1"
    reset_color
}

log_warning() {
    echo -e "${BOLD_YELLOW}[!]${NC} $1"
    reset_color
}

log_error() {
    echo -e "${BOLD_RED}[✗]${NC} $1" >&2
    reset_color
}

# --- Argument Validation Functions ---
validate_rate_limit() {
    local rate=$1
    if [[ ! $rate =~ ^[0-9]+/(second|minute|hour)$ ]]; then
        log_error "Invalid rate limit format: $rate (e.g., 150/minute)"
        return 1
    fi
    
    local value=${rate%/*}
    local unit=${rate#*/}
    
    case $unit in
        second)
            [[ $value -le 10 ]] || { log_error "Maximum rate per second is 10"; return 1; }
            ;;
        minute)
            [[ $value -le 300 ]] || { log_error "Maximum rate per minute is 300"; return 1; }
            ;;
        hour)
            [[ $value -le 10000 ]] || { log_error "Maximum rate per hour is 10000"; return 1; }
            ;;
    esac
    return 0
}

# --- Argument Parsing ---
parse_args() {
    # Default values
    TARGET=""
    THREADS=$DEFAULT_THREADS
    TIMEOUT=$DEFAULT_TIMEOUT
    RATE_LIMIT=$DEFAULT_RATE_LIMIT
    COMMAND=$DEFAULT_COMMAND
    OUTPUT_FORMAT=$DEFAULT_OUTPUT_FORMAT
    
    # Flag variables
    DO_RECON_FAST=false
    DO_RECON_DEEP=false
    DO_DNS_ENUM=false
    DO_VULN_SCAN=false
    DO_RESUME=false
    SHOW_HELP=false
    SHOW_VERSION=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--target)
                TARGET="$2"
                shift 2
                ;;
            -T|--threads)
                if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -le "$MAX_THREADS" ]; then
                    THREADS="$2"
                else
                    log_error "Invalid thread count: $2 (max: $MAX_THREADS)"
                    exit 1
                fi
                shift 2
                ;;
            -O|--timeout)
                if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge "$MIN_TIMEOUT" ]; then
                    TIMEOUT="$2"
                else
                    log_error "Invalid timeout: $2 (min: $MIN_TIMEOUT)"
                    exit 1
                fi
                shift 2
                ;;
            -R|--rate)
                validate_rate_limit "$2" || exit 1
                RATE_LIMIT="$2"
                shift 2
                ;;
            -RF|--recon-fast)
                DO_RECON_FAST=true
                COMMAND="recon_fast"
                shift
                ;;
            -RD|--recon-deep)
                DO_RECON_DEEP=true
                COMMAND="recon_deep"
                shift
                ;;
            -D|--dns)
                DO_DNS_ENUM=true
                COMMAND="dns_enum"
                shift
                ;;
            -V|--vuln)
                DO_VULN_SCAN=true
                COMMAND="vuln_scan"
                shift
                ;;
            -RP|--resume)
                DO_RESUME=true
                shift
                ;;
            -h|--help)
                SHOW_HELP=true
                shift
                ;;
            --version)
                SHOW_VERSION=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Check for help or version flags first
    if $SHOW_HELP; then
        show_help
        exit 0
    fi
    
    if $SHOW_VERSION; then
        show_version
        exit 0
    fi
    
    # Handle resume separately
    if $DO_RESUME; then
        if [ ! -f "$RESUME_FILE" ]; then
            log_error "No resume data found"
            exit 1
        fi
        return 0
    fi
    
    # Validate required arguments
    if [ -z "$TARGET" ]; then
        if [ -n "$DEFAULT_TARGET" ]; then
            TARGET="$DEFAULT_TARGET"
            log_info "Using default target: $TARGET"
        else
            log_error "No target specified. Use -t or --target to specify a target domain."
            show_help
            exit 1
        fi
    fi
    
    # Validate at least one command is selected
    if ! $DO_RECON_FAST && ! $DO_RECON_DEEP && ! $DO_DNS_ENUM && ! $DO_VULN_SCAN; then
        log_info "No scan type specified, defaulting to fast recon"
        DO_RECON_FAST=true
        COMMAND="recon_fast"
    fi
}

# --- Initialization ---
init_environment() {
    # Create required directories
    mkdir -p "$LOG_DIR" "$CONFIG_DIR" "$RECOVERY_DIR" "$PROGRESS_DIR" "$HUNT_DIR"
    
    # Initialize configuration if not exists
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
{
    "threads": $DEFAULT_THREADS,
    "timeout": $DEFAULT_TIMEOUT,
    "rate_limit": "$DEFAULT_RATE_LIMIT",
    "output_format": "$DEFAULT_OUTPUT_FORMAT",
    "default_command": "$DEFAULT_COMMAND"
}
EOF
    fi
    
    # Set up logging
    LOG_FILE="$LOG_DIR/shadowwalker-$(date +%Y%m%d-%H%M%S).log"
    exec 2> >(tee -a "$LOG_FILE" >&2)
}

# --- Display Functions ---
show_banner() {
    cat << "EOF"
    
███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║
███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║
╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║
███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝ 
██╗    ██╗ █████╗ ██╗     ██╗  ██╗███████╗██████╗ 
██║    ██║██╔══██╗██║     ██║ ██╔╝██╔════╝██╔══██╗
██║ █╗ ██║███████║██║     █████╔╝ █████╗  ██████╔╝
██║███╗██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
╚███╔███╔╝██║  ██║███████╗██║  ██╗███████╗██║  ██║
 ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
EOF
    echo -e "\n${BOLD_CYAN}[ ShadowWalker Universal Recon Suite v${VERSION} ]${NC}"
    echo -e "${BOLD_PURPLE}[ Created by: Mohamed Sayed (ShadowVoidxKing) ]${NC}"
    echo -e "${BOLD_BLUE}[ Build: ${BUILD_DATE} - ${DISTRO_TYPE} Edition ]${NC}\n"
}

show_help() {
    show_banner
    cat << EOF
${BOLD_YELLOW}USAGE:${NC}
    $0 [OPTIONS] -t <target> [COMMANDS]

${BOLD_YELLOW}COMMANDS:${NC}
    -RF, --recon-fast        Quick reconnaissance scan
        Tools: subfinder, findomain, assetfinder, httpx
    
    -RD, --recon-deep        Deep reconnaissance scan
        Tools: amass, dnsgen, puredns, subfinder, findomain
    
    -D,  --dns               DNS enumeration scan
        Tools: dnsx, amass, puredns, massdns
    
    -V,  --vuln-scan        Vulnerability scan
        Tools: nuclei, httpx, katana, gf-patterns
    
    -RP, --resume-progress   Resume last interrupted scan
    -LP, --list-progress    List available progress points

${BOLD_YELLOW}TARGET OPTIONS:${NC}
    -t,  --target           Target domain
    -i,  --input           Input file with targets/domains
    -o,  --output          Custom output directory

${BOLD_YELLOW}SCAN CONTROL:${NC}
    -T,  --threads         Number of threads (default: ${DEFAULT_THREADS})
    -O,  --timeout        Timeout in seconds (default: ${DEFAULT_TIMEOUT})
    -r,  --rate-limit     Rate limit for requests (default: ${DEFAULT_RATE_LIMIT})

${BOLD_YELLOW}TOOL MANAGEMENT:${NC}
    -c,  --check          Check tool dependencies
    --install            Install required tools
    --update            Update installed tools

${BOLD_YELLOW}EXAMPLES:${NC}
    # Basic reconnaissance
    $0 -t example.com -RF

    # Deep scan with custom parameters
    $0 -t example.com -RD -T 20 -O 45

    # Resume interrupted scan
    $0 -RP

    # Multiple operations
    $0 -t example.com -RF -D -V

${BOLD_YELLOW}NOTES:${NC}
    - Results are saved in: ~/Hunt/<domain>/
    - Logs are stored in: ~/.shadowwalker/logs/
    - Recovery points: ~/.shadowwalker/recovery/
    - Configuration: ~/.shadowwalker/config/config.json
EOF
}

show_version() {
    echo -e "${BOLD_CYAN}ShadowWalker v${VERSION} (${CODENAME})${NC}"
    echo -e "${BOLD_BLUE}Build Date: ${BUILD_DATE}${NC}"
}

# --- Scan Functions ---

recon_fast() {
    local domain=$1
    local outdir="$HUNT_DIR/$domain/recon"
    mkdir -p "$outdir"
    
    log_info "Starting fast reconnaissance for $domain"
    
    # Run subfinder with error suppression
    if command -v subfinder &> /dev/null; then
        log_info "Running subfinder..."
        subfinder -d "$domain" -t "$THREADS" -o "$outdir/subfinder.txt" 2>/dev/null || true
    fi
    
    # Run findomain with error suppression
    if command -v findomain &> /dev/null; then
        log_info "Running findomain..."
        findomain --quiet -t "$domain" -u "$outdir/findomain.txt" 2>/dev/null || true
    fi
    
    # Run assetfinder as backup
    if command -v assetfinder &> /dev/null; then
        log_info "Running assetfinder..."
        assetfinder --subs-only "$domain" > "$outdir/assetfinder.txt" 2>/dev/null || true
    fi
    
    # Combine results and filter
    if ls "$outdir"/*.txt &>/dev/null; then
        cat "$outdir"/*.txt 2>/dev/null | sort -u > "$outdir/all_domains_raw.txt"
        filter_results "$outdir/all_domains_raw.txt" "$outdir/subdomains.txt"
        
        # Resolve live hosts
        if command -v httpx &> /dev/null; then
            log_info "Resolving live hosts..."
            cat "$outdir/subdomains.txt" | httpx -silent -threads "$THREADS" \
                -rate-limit "$RATE_LIMIT" -o "$outdir/live_hosts.txt" 2>/dev/null || true
            log_success "Found $(wc -l < "$outdir/live_hosts.txt") live hosts"
        fi
    fi
    
    return 0
}

recon_deep() {
    local domain=$1
    local outdir="$HUNT_DIR/$domain/recon"
    mkdir -p "$outdir"
    
    # Run fast recon first
    recon_fast "$domain"
    
    log_info "Starting deep reconnaissance for $domain"
    
    # Run amass if available
    if command -v amass &> /dev/null; then
        log_info "Running amass passive scan..."
        amass enum -passive -d "$domain" -o "$outdir/amass.txt" 2>/dev/null || true
    fi
    
    # Run dnsgen with error handling
    if command -v dnsgen &> /dev/null && [ -f "$outdir/subdomains.txt" ]; then
        log_info "Generating DNS permutations..."
        cat "$outdir/subdomains.txt" | dnsgen - > "$outdir/permutations.txt" 2>/dev/null || true
        
        # Resolve permutations with puredns
        if command -v puredns &> /dev/null; then
            log_info "Resolving permutations..."
            puredns resolve "$outdir/permutations.txt" -r "$RESOLVERS_LIST" \
                --rate-limit-trusted "$RATE_LIMIT" -w "$outdir/resolved_perms.txt" 2>/dev/null || true
        fi
    fi
    
    # Combine and filter all results
    cat "$outdir"/{subdomains.txt,amass.txt,resolved_perms.txt} 2>/dev/null | sort -u > "$outdir/all_domains_raw.txt"
    filter_results "$outdir/all_domains_raw.txt" "$outdir/all_domains_filtered.txt"
    
    log_success "Total unique domains after filtering: $(wc -l < "$outdir/all_domains_filtered.txt")"
    return 0
}

dns_enum() {
    local domain=$1
    local outdir="$HUNT_DIR/$domain/dns"
    mkdir -p "$outdir"
    
    log_info "Starting DNS enumeration for $domain"
    
    # Run amass if available
    if command -v amass &> /dev/null; then
        log_info "Running amass..."
        amass enum -d "$domain" -o "$outdir/amass.txt" 2>/dev/null || true
    fi
    
    # Run dnsx if available
    if command -v dnsx &> /dev/null; then
        log_info "Running dnsx..."
        cat "$outdir"/*.txt 2>/dev/null | sort -u | dnsx -silent -a -aaaa -cname \
            -o "$outdir/dns_records.txt" 2>/dev/null || true
    fi
    
    log_success "DNS enumeration completed"
    return 0
}

vuln_scan() {
    local domain=$1
    local outdir="$HUNT_DIR/$domain/vulns"
    mkdir -p "$outdir"
    
    log_info "Starting vulnerability scan for $domain"
    
    # Run nuclei if available
    if command -v nuclei &> /dev/null; then
        log_info "Running nuclei scan..."
        nuclei -u "https://$domain" -t "$THREADS" -rate-limit "$RATE_LIMIT" \
            -o "$outdir/nuclei.txt" 2>/dev/null || true
    fi
    
    # Run httpx for tech detection
    if command -v httpx &> /dev/null; then
        log_info "Running technology detection..."
        echo "$domain" | httpx -silent -tech-detect -title -status-code \
            -o "$outdir/tech.txt" 2>/dev/null || true
    fi
    
    log_success "Vulnerability scan completed"
    return 0
}

# --- Recovery Functions ---

save_progress() {
    local domain=$1
    local phase=$2
    local status=$3
    
    mkdir -p "$PROGRESS_DIR"
    local progress_file="$PROGRESS_DIR/${domain}_progress.json"
    
    # Save progress data
    cat > "$progress_file" << EOF
{
    "domain": "$domain",
    "phase": "$phase",
    "status": "$status",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M%S")",
    "threads": $THREADS,
    "timeout": $TIMEOUT,
    "rate_limit": "$RATE_LIMIT"
}
EOF
}

resume_scan() {
    if [[ ! -f "$RESUME_FILE" ]]; then
        return 1
    fi
    
    local domain=$(jq -r .domain "$RESUME_FILE")
    local phase=$(jq -r .phase "$RESUME_FILE")
    
    case "$phase" in
        "recon_fast") recon_fast "$domain" ;;
        "recon_deep") recon_deep "$domain" ;;
        "dns_enum") dns_enum "$domain" ;;
        "vuln_scan") vuln_scan "$domain" ;;
        *) log_error "Unknown phase: $phase"; return 1 ;;
    esac
}

run_with_recovery() {
    local domain=$1
    local phase=$2
    local func=$3
    
    log_info "Starting $phase for $domain"
    save_progress "$domain" "$phase" "started"
    
    if $func "$domain"; then
        save_progress "$domain" "$phase" "completed"
        log_success "$phase completed successfully"
        return 0
    else
        save_progress "$domain" "$phase" "failed"
        log_error "$phase failed - Use --resume to continue"
        return 1
    fi
}

# --- Main Function ---
run() {
    init_colors
    init_environment
    
    # Show banner
    display_banner
    
    # Parse arguments
    parse_args "$@"
    
    # Handle commands
    if $DO_RESUME; then
        resume_scan
    else
        if $DO_RECON_FAST; then
            run_with_recovery "$TARGET" "Fast Reconnaissance" recon_fast
        fi
        
        if $DO_RECON_DEEP; then
            run_with_recovery "$TARGET" "Deep Reconnaissance" recon_deep
        fi
        
        if $DO_DNS_ENUM; then
            run_with_recovery "$TARGET" "DNS Enumeration" dns_enum
        fi
        
        if $DO_VULN_SCAN; then
            run_with_recovery "$TARGET" "Vulnerability Scan" vuln_scan
        fi
    fi
    
    log_success "All operations completed successfully!"
}

# Start execution
run "$@"
