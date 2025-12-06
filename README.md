# swiss-army-vm

A collection of Packer configuration files that allow you to automatically build a Debian-based virtual machine preloaded with cybersecurity, pentesting, and digital forensics tools.

---

## Prerequisites

Install the VMWare plugin required for Packer:

` packer plugins install github.com/hashicorp/vmware`

Verify installation:

`packer plugins list`

---

## Build Instructions

Initialize Packer:

`packer init swiss-army-vm.pkr.hcl`

Build the VM:

`packer build swiss-army-vm.pkr.hcl`

---

## Accessing Tools Inside the VM

Once the VM boots, login and use the following commands to run tools.

### 1. Network Traffic Monitoring and Analysis

#### Wireshark

`sudo wireshark`

#### Tshark

`sudo tshark`

#### Tcpdump

`tcpdump`

#### Net-tools

#### Ngrep

`sudo ngrep [options] [pattern] [filter]`

#### Zeek

`zeek [options] [scripts] -r pcap_file `

#### Tcpreplay

`sudo tcpreplay [options] -i <interface> <pcap_file>`

#### Hping3

`sudo hping3 [mode/options] [target]`

#### Scapy

`sudo scapy`

#### tcpflow

`sudo tcpflow -i <interface>` for live capture or `tcpflow -r <pcapfile>` to analyze saved captures

---

### 2. Vulnerability Assessment

#### Metasploit

`msfconsole`

#### Nmap

`sudo nmap [options]`

#### Burp Suite

`sudo BurpSuiteCommunity`

#### Nuclei

`nuclei [options]`

#### Lynis

`lynis [options]`

#### Trivy

`trivy <target_type> <target>`

#### Nikto

`nikto`

#### OpenSCAP

`oscap xccdf eval [options] [content-file]`

Common Options:
`--profile [id]` - Select security profile to scan
`--results [file]` - Save results to XML file
`--report [file]` - Generate HTML report

#### Wapiti

`wapiti -u <target_url>`

#### Cloudsploit

#### Prowler

#### ffuf

`ffuf -w /path/to/wordlist -u <target>`

#### gobuster

`gobuster -h`

---

### 3. Endpoint Analysis

#### Velociraptor

`velociraptor`

#### Osquery

`osqueryi`

#### Volatility3

#### Log2timeline

`log2timeline <output_file> <source>`

#### Dumpzilla

`dumpzilla --help`

#### ExifTool

`exiftool [options] [file(s)]`

#### RegRipper

`rip [-r hive_file] [-f profile] [-p plugin] [options]`

#### Evtx

---

### 4. File Analysis

#### Binwalk

`binwalk [options] <targetfile>`

#### GDB

`gdb`

#### Hashdeep

`hashdeep -h`

#### Yara

`yara [options] RULES_FILE TARGET`

#### Virus Total

---

#### CyberChef
