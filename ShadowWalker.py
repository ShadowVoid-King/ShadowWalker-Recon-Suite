#!/usr/bin/env python3

"""
ShadowWalker Universal Recon Suite v1.5.6
----------------------------------------
Author: Mohamed Sayed (ShadowVoidxKing)
Updated: June 15, 2025

Universal reconnaissance framework for all pentesting environments.
Combined features from Segfault and Kali editions with enhanced
recovery system and environment detection.
"""

import os
import sys
import json
import logging
import argparse
import platform
import subprocess
import shutil
import re
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List, Union, Set, Tuple
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor
import colorama
from colorama import Fore, Style
from rich.console import Console
from rich.progress import Progress, SpinnerColumn
from rich import print as rprint

# Initialize colorama for cross-platform color support
colorama.init()

@dataclass
class Config:
    """Configuration class for ShadowWalker"""
    version: str = "1.5.7"
    build_date: str = "2025-06-15"
    codename: str = "FilterHunter"
    
    # Directory structure
    home_dir: Path = Path.home() / ".shadowwalker"
    log_dir: Path = home_dir / "logs"
    config_dir: Path = home_dir / "config"
    recovery_dir: Path = home_dir / "recovery"
    progress_dir: Path = home_dir / "progress"
    hunt_dir: Path = Path.home() / "Hunt"
    
    # Default settings
    default_threads: int = 10
    default_timeout: int = 30
    default_rate_limit: str = "150/minute"
    default_output_format: str = "json"
    default_command: str = "recon_fast"
    
    # Limits
    max_threads: int = 50
    min_timeout: int = 5
    max_rate: str = "300/minute"
    
    def __post_init__(self):
        """Create necessary directories on initialization"""
        for directory in [self.log_dir, self.config_dir, 
                         self.recovery_dir, self.progress_dir]:
            directory.mkdir(parents=True, exist_ok=True)
        
        # Initialize config file if it doesn't exist
        config_file = self.config_dir / "config.json"
        if not config_file.exists():
            config_data = {
                "threads": self.default_threads,
                "timeout": self.default_timeout,
                "rate_limit": self.default_rate_limit,
                "output_format": self.default_output_format,
                "default_command": self.default_command
            }
            with open(config_file, 'w') as f:
                json.dump(config_data, f, indent=4)

class ShadowWalker:
    def __init__(self):
        self.config = Config()
        self.console = Console()
        self.setup_logging()
        
    def setup_logging(self):
        """Configure logging to file and console"""
        log_file = self.config.log_dir / f"shadowwalker-{datetime.now():%Y%m%d-%H%M%S}.log"
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )
    
    def display_banner(self):
        """Display the ShadowWalker banner"""
        banner = f"""
{Fore.CYAN}███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║
███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║
╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║
███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝{Style.RESET_ALL} 
{Fore.BLUE}██╗    ██╗ █████╗ ██╗     ██╗  ██╗███████╗██████╗ 
██║    ██║██╔══██╗██║     ██║ ██╔╝██╔════╝██╔══██╗
██║ █╗ ██║███████║██║     █████╔╝ █████╗  ██████╔╝
██║███╗██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
╚███╔███╔╝██║  ██║███████╗██║  ██╗███████╗██║  ██║
 ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝{Style.RESET_ALL}

{Fore.GREEN}[ 🚀 ShadowWalker Universal Recon Suite v{self.config.version} ]{Style.RESET_ALL}
{Fore.MAGENTA}[ 👑 Created by: Mohamed Sayed (ShadowVoidxKing) ]{Style.RESET_ALL}
{Fore.BLUE}[ 🔧 Build: {self.config.build_date} - Python Edition ]{Style.RESET_ALL}
"""
        print(banner)
    
    def parse_args(self):
        """Parse command line arguments"""
        parser = argparse.ArgumentParser(
            description="ShadowWalker Universal Recon Suite",
            formatter_class=argparse.RawDescriptionHelpFormatter
        )
        
        # Target options
        parser.add_argument('-t', '--target', help='Target domain to scan')
        
        # Scan types
        parser.add_argument('-RF', '--recon-fast', action='store_true', 
                          help='Quick reconnaissance scan')
        parser.add_argument('-RD', '--recon-deep', action='store_true',
                          help='Deep reconnaissance scan')
        parser.add_argument('-D', '--dns', action='store_true',
                          help='DNS enumeration scan')
        parser.add_argument('-V', '--vuln', action='store_true',
                          help='Vulnerability scan')
        
        # Scan control
        parser.add_argument('-T', '--threads', type=int, default=self.config.default_threads,
                          help=f'Number of threads (default: {self.config.default_threads})')
        parser.add_argument('-O', '--timeout', type=int, default=self.config.default_timeout,
                          help=f'Timeout in seconds (default: {self.config.default_timeout})')
        parser.add_argument('-R', '--rate', default=self.config.default_rate_limit,
                          help=f'Rate limit for requests (default: {self.config.default_rate_limit})')
        
        # Progress & Recovery
        parser.add_argument('-RP', '--resume', action='store_true',
                          help='Resume last interrupted scan')
        parser.add_argument('-LP', '--list-progress', action='store_true',
                          help='List available recovery points')
        parser.add_argument('-s', '--save', action='store_true',
                          help='Save progress point')
        
        args = parser.parse_args()
        
        # Validate arguments
        if not any([args.recon_fast, args.recon_deep, args.dns, args.vuln, 
                   args.resume, args.list_progress]):
            if args.target:
                print(f"{Fore.YELLOW}[!] No scan type specified, defaulting to fast recon{Style.RESET_ALL}")
                args.recon_fast = True
            elif not args.list_progress:
                parser.print_help()
                sys.exit(1)
        
        return args
    
    def filter_results(self, input_file: Path, output_file: Path) -> None:
        """Filter domain results to remove false positives and noise"""
        logging.info("Filtering results...")
        
        # Compile regex patterns
        static_files = re.compile(r'(_|\.)(?:css|js|jpg|jpeg|png|gif|ico|woff|woff2|ttf|eot|svg)$')
        cdn_domains = re.compile(r'(?:cloudfront\.net|cloudflare\.com|amazonaws\.com|googleusercontent\.com)$')
        test_envs = re.compile(r'(?:test|staging|dev|local|localhost)')
        numeric_subs = re.compile(r'^[0-9]+')
        
        filtered = set()
        with open(input_file) as f:
            for line in f:
                domain = line.strip()
                if (not any(pattern.search(domain) for pattern in 
                    [static_files, cdn_domains, test_envs, numeric_subs])):
                    filtered.add(domain)
        
        with open(output_file, 'w') as f:
            for domain in sorted(filtered):
                f.write(f"{domain}\n")
        
        logging.info(f"Filtered {len(filtered)} domains")
    
    def run_tool(self, cmd: list, input_data: str = None) -> tuple[str, str]:
        """Run a command and return stdout and stderr"""
        try:
            process = subprocess.run(
                cmd,
                input=input_data.encode() if input_data else None,
                capture_output=True,
                text=True
            )
            return process.stdout, process.stderr
        except Exception as e:
            logging.error(f"Error running {cmd[0]}: {str(e)}")
            return "", str(e)

    def run_recon_fast(self, target: str, outdir: Path) -> dict:
        """Run fast reconnaissance scan"""
        results = {"subdomains": set(), "live_hosts": set()}
        
        # Run subfinder
        if self.check_tool("subfinder"):
            stdout, _ = self.run_tool([
                "subfinder", "-d", target,
                "-t", str(self.args.threads),
            ])
            results["subdomains"].update(stdout.splitlines())
        
        # Run findomain
        if self.check_tool("findomain"):
            stdout, _ = self.run_tool([
                "findomain", "--quiet", "-t", target
            ])
            results["subdomains"].update(stdout.splitlines())
        
        # Run assetfinder
        if self.check_tool("assetfinder"):
            stdout, _ = self.run_tool([
                "assetfinder", "--subs-only", target
            ])
            results["subdomains"].update(stdout.splitlines())
        
        # Filter and save results
        if results["subdomains"]:
            raw_file = outdir / "all_domains_raw.txt"
            filtered_file = outdir / "subdomains.txt"
            
            with open(raw_file, 'w') as f:
                f.write('\n'.join(sorted(results["subdomains"])))
            
            self.filter_results(raw_file, filtered_file)
            
            # Run httpx on filtered results
            if self.check_tool("httpx"):
                with open(filtered_file) as f:
                    domains = f.read()
                stdout, _ = self.run_tool([
                    "httpx", "-silent",
                    "-threads", str(self.args.threads),
                    "-rate-limit", self.args.rate
                ], domains)
                results["live_hosts"].update(stdout.splitlines())
                
                # Save live hosts
                with open(outdir / "live_hosts.txt", 'w') as f:
                    f.write('\n'.join(sorted(results["live_hosts"])))
        
        return results

    def run_dns_enum(self, target: str, outdir: Path) -> dict:
        """Run DNS enumeration scan"""
        results = {"records": []}
        
        # Run amass
        if self.check_tool("amass"):
            stdout, _ = self.run_tool([
                "amass", "enum", "-passive", "-d", target
            ])
            if stdout:
                with open(outdir / "amass.txt", 'w') as f:
                    f.write(stdout)
        
        # Run dnsx
        if self.check_tool("dnsx"):
            stdout, _ = self.run_tool([
                "dnsx", "-d", target,
                "-a", "-aaaa", "-cname", "-mx", "-ns",
                "-silent"
            ])
            if stdout:
                results["records"].extend(stdout.splitlines())
                with open(outdir / "dns_records.txt", 'w') as f:
                    f.write(stdout)
        
        return results
    
    def run_recon_deep(self, target: str, outdir: Path) -> dict:
        """Run deep reconnaissance scan"""
        results = {
            "subdomains": set(),
            "live_hosts": set(),
            "endpoints": set(),
            "technologies": []
        }
        
        # Run Amass for thorough enumeration
        if self.check_tool("amass"):
            stdout, _ = self.run_tool([
                "amass", "enum", "-active", "-d", target,
                "-timeout", str(self.args.timeout),
                "-max-dns-queries", "500"
            ])
            results["subdomains"].update(stdout.splitlines())
        
        # Run Nuclei for tech detection
        if self.check_tool("nuclei"):
            with open(outdir / "nuclei_tech.txt", 'w') as f:
                stdout, _ = self.run_tool([
                    "nuclei", "-t", "technologies",
                    "-u", target,
                    "-rate-limit", self.args.rate,
                    "-timeout", str(self.args.timeout)
                ])
                f.write(stdout)
                results["technologies"] = stdout.splitlines()
        
        # Run waybackurls for endpoint discovery
        if self.check_tool("waybackurls"):
            stdout, _ = self.run_tool(["waybackurls", target])
            results["endpoints"].update(stdout.splitlines())
            
            # Save endpoints
            with open(outdir / "endpoints.txt", 'w') as f:
                f.write('\n'.join(sorted(results["endpoints"])))
        
        # Filter and resolve subdomains like in fast scan
        if results["subdomains"]:
            raw_file = outdir / "all_domains_raw.txt"
            filtered_file = outdir / "subdomains.txt"
            
            with open(raw_file, 'w') as f:
                f.write('\n'.join(sorted(results["subdomains"])))
            
            self.filter_results(raw_file, filtered_file)
            
            # Run httpx
            if self.check_tool("httpx"):
                with open(filtered_file) as f:
                    domains = f.read()
                stdout, _ = self.run_tool([
                    "httpx", "-silent",
                    "-threads", str(self.args.threads),
                    "-rate-limit", self.args.rate,
                    "-tech-detect"
                ], domains)
                results["live_hosts"].update(stdout.splitlines())
                
                # Save live hosts with tech info
                with open(outdir / "live_hosts_tech.txt", 'w') as f:
                    f.write('\n'.join(sorted(results["live_hosts"])))
        
        return results
    
    def run_vuln_scan(self, target: str, outdir: Path) -> dict:
        """Run vulnerability scan"""
        results = {"vulnerabilities": []}
        
        # Run Nuclei vulnerability templates
        if self.check_tool("nuclei"):
            logging.info("Running vulnerability scan with Nuclei...")
            
            # Basic vulnerability scan
            stdout, _ = self.run_tool([
                "nuclei", "-u", target,
                "-t", "cves,vulnerabilities,misconfiguration",
                "-rate-limit", self.args.rate,
                "-timeout", str(self.args.timeout),
                "-severity", "critical,high,medium",
                "-silent"
            ])
            
            if stdout:
                results["vulnerabilities"].extend(stdout.splitlines())
                with open(outdir / "vulnerabilities.txt", 'w') as f:
                    f.write(stdout)
            
            # Targeted scans based on tech detection
            tech_file = outdir.parent / "recon_deep" / "nuclei_tech.txt"
            if tech_file.exists():
                tech_data = tech_file.read_text()
                
                # Run specific templates based on detected tech
                if "wordpress" in tech_data.lower():
                    stdout, _ = self.run_tool([
                        "nuclei", "-u", target,
                        "-t", "wordpress",
                        "-rate-limit", self.args.rate,
                        "-silent"
                    ])
                    if stdout:
                        results["vulnerabilities"].extend(stdout.splitlines())
                
                if "apache" in tech_data.lower():
                    stdout, _ = self.run_tool([
                        "nuclei", "-u", target,
                        "-t", "apache",
                        "-rate-limit", self.args.rate,
                        "-silent"
                    ])
                    if stdout:
                        results["vulnerabilities"].extend(stdout.splitlines())
        return results
    
    def run_scan(self, scan_type: str, target: str):
        """Run a specific type of scan"""
        scan_dir = self.config.hunt_dir / target / scan_type
        scan_dir.mkdir(parents=True, exist_ok=True)
        
        with Progress(SpinnerColumn(), *Progress.get_default_columns()) as progress:
            task = progress.add_task(f"[cyan]Running {scan_type}...", total=100)
            
            try:
                results = {}
                if scan_type == "recon_fast":
                    results = self.run_recon_fast(target, scan_dir)
                    if results.get("subdomains"):
                        logging.info(f"Found {len(results['subdomains'])} subdomains")
                    if results.get("live_hosts"):
                        logging.info(f"Found {len(results['live_hosts'])} live hosts")
                
                elif scan_type == "recon_deep":
                    results = self.run_recon_deep(target, scan_dir)
                    if results.get("subdomains"):
                        logging.info(f"Found {len(results['subdomains'])} total subdomains")
                    if results.get("endpoints"):
                        logging.info(f"Found {len(results['endpoints'])} endpoints")
                    if results.get("technologies"):
                        logging.info(f"Found {len(results['technologies'])} technologies")
                
                elif scan_type == "dns_enum":
                    results = self.run_dns_enum(target, scan_dir)
                    if results.get("records"):
                        logging.info(f"Found {len(results['records'])} DNS records")
                
                elif scan_type == "vuln_scan":
                    results = self.run_vuln_scan(target, scan_dir)
                    if results.get("vulnerabilities"):
                        logging.info(f"Found {len(results['vulnerabilities'])} potential vulnerabilities")
                
                # Save final results
                results_file = scan_dir / f"{scan_type}_results.json"
                with open(results_file, 'w') as f:
                    json.dump(results, f, indent=4)
                
                # If progress saving is enabled, save the results
                if self.args.save:
                    self.save_progress(scan_type, target, results)
                
                progress.update(task, completed=100)
                
            except Exception as e:
                logging.error(f"Error during {scan_type}: {str(e)}")
                results_file = scan_dir / f"{scan_type}_error.json"
                with open(results_file, 'w') as f:
                    json.dump({"error": str(e), "status": "failed"}, f, indent=4)
                raise
            
    def save_progress(self, scan_type: str, target: str, results: dict) -> None:
        """Save scan progress to a recovery file"""
        progress_file = self.config.progress_dir / f"{target}_{scan_type}_{datetime.now():%Y%m%d-%H%M%S}.json"
        
        progress_data = {
            "timestamp": datetime.now().isoformat(),
            "target": target,
            "scan_type": scan_type,
            "results": results,
            "complete": False
        }
        
        with open(progress_file, 'w') as f:
            json.dump(progress_data, f, indent=4)
        
        logging.info(f"Progress saved to {progress_file}")
    
    def list_progress_points(self) -> List[dict]:
        """List all available progress recovery points"""
        progress_points = []
        
        for file in self.config.progress_dir.glob("*.json"):
            try:
                with open(file) as f:
                    data = json.load(f)
                    data["file"] = str(file)
                    progress_points.append(data)
            except json.JSONDecodeError:
                logging.warning(f"Corrupt progress file: {file}")
                continue
        
        return sorted(progress_points, key=lambda x: x["timestamp"], reverse=True)
    
    def display_progress_points(self):
        """Display available progress recovery points"""
        points = self.list_progress_points()
        
        if not points:
            print(f"\n{Fore.YELLOW}[!] No progress recovery points found{Style.RESET_ALL}")
            return
        
        print(f"\n{Fore.CYAN}Available Recovery Points:{Style.RESET_ALL}")
        for i, point in enumerate(points, 1):
            complete = "✓" if point.get("complete") else "..."
            print(f"{Fore.GREEN}[{i}] {point['timestamp']} - {point['scan_type']} - {complete}{Style.RESET_ALL}")
    
    def resume_scan(self, progress_file: Path):
        """Resume a scan from a recovery point"""
        try:
            with open(progress_file) as f:
                progress_data = json.load(f)
            
            target = progress_data["target"]
            scan_type = progress_data["scan_type"]
            results = progress_data["results"]
            
            logging.info(f"Resuming {scan_type} for {target} from {progress_file}")
            
            # Recreate the scan directory
            scan_dir = self.config.hunt_dir / target / scan_type
            scan_dir.mkdir(parents=True, exist_ok=True)
            
            # Save the initial progress
            self.save_progress(scan_type, target, results)
            
            with Progress(SpinnerColumn(), *Progress.get_default_columns()) as progress:
                task = progress.add_task(f"[cyan]Resuming {scan_type}...", total=100)
                
                # Resume logic based on scan type
                if scan_type == "recon_fast":
                    self.run_recon_fast(target, scan_dir)
                
                elif scan_type == "recon_deep":
                    self.run_recon_deep(target, scan_dir)
                
                elif scan_type == "dns_enum":
                    self.run_dns_enum(target, scan_dir)
                
                elif scan_type == "vuln_scan":
                    self.run_vuln_scan(target, scan_dir)
                
                progress.update(task, completed=100)
            
            # Mark as complete
            results_file = scan_dir / f"{scan_type}_results.json"
            if results_file.exists():
                with open(results_file) as f:
                    final_results = json.load(f)
                self.save_progress(scan_type, target, final_results)
        
        except Exception as e:
            logging.error(f"Error resuming scan: {str(e)}")
            raise
    
    def check_tool(self, tool_name: str) -> bool:
        """Check if a required tool is available"""
        result = shutil.which(tool_name)
        if not result:
            logging.error(f"Required tool not found: {tool_name}")
        return result is not None
    
    def main(self):
        """Main execution function"""
        try:
            self.display_banner()
            self.args = self.parse_args()
            
            # List progress points
            if self.args.list_progress:
                self.display_progress_points()
                return
            
            # Resume from checkpoint
            if self.args.resume:
                points = self.list_progress_points()
                if not points:
                    print(f"\n{Fore.YELLOW}[!] No progress recovery points found{Style.RESET_ALL}")
                    sys.exit(1)
                
                self.display_progress_points()
                
                while True:
                    try:
                        choice = int(input("\nEnter recovery point number to resume: "))
                        if 1 <= choice <= len(points):
                            self.resume_scan(Path(points[choice - 1]["file"]))
                            break
                        print(f"{Fore.YELLOW}Invalid choice. Please enter a number between 1 and {len(points)}{Style.RESET_ALL}")
                    except ValueError:
                        print(f"{Fore.YELLOW}Please enter a valid number{Style.RESET_ALL}")
                return
            
            # Regular scan execution
            if self.args.target:
                try:
                    if self.args.recon_fast:
                        self.run_scan("recon_fast", self.args.target)
                    if self.args.recon_deep:
                        self.run_scan("recon_deep", self.args.target)
                    if self.args.dns:
                        self.run_scan("dns_enum", self.args.target)
                    if self.args.vuln:
                        self.run_scan("vuln_scan", self.args.target)
                    
                    print(f"\n{Fore.GREEN}[✓] All operations completed successfully!{Style.RESET_ALL}")
                
                except KeyboardInterrupt:
                    print(f"\n{Fore.YELLOW}[!] Scan interrupted. Saving progress...{Style.RESET_ALL}")
                    if self.args.save:
                        # Save progress for the interrupted scan
                        scan_type = next((s for s in ["recon_fast", "recon_deep", "dns_enum", "vuln_scan"] 
                                      if getattr(self.args, s.replace("_", "-"))), None)
                        if scan_type:
                            scan_dir = self.config.hunt_dir / self.args.target / scan_type
                            results_file = scan_dir / f"{scan_type}_results.json"
                            if results_file.exists():
                                with open(results_file) as f:
                                    results = json.load(f)
                                self.save_progress(scan_type, self.args.target, results)
                    sys.exit(1)
            
        except KeyboardInterrupt:
            print(f"\n{Fore.YELLOW}[!] Operation interrupted by user{Style.RESET_ALL}")
            sys.exit(1)
        except Exception as e:
            logging.error(f"An error occurred: {str(e)}")
            sys.exit(1)
