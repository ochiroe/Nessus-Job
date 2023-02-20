# Nessus-Job
Automated Nessus scans with E-mail Report & Web Report

# Requirements

IIS Web Service
Posh-Nessus Module
Tenable.SC or Tenable.io (Nessus API Supported)
E-Mail Service (SMTP)

# Usage

{Path}\Nessus-Job.ps1 -nName "{{ Scan name }}" -nTarget "{{ Target IP Address }}" -email "{{ recipient-email }}"

