# pwsh-vcs
VCS in pure powershell

# PowerShell Local VCS — Project Roadmap & Test Framework

This document defines a **phased, byte-sized roadmap** for building a **single-user, local, git-like VCS implemented entirely in PowerShell**, using **default PowerShell modules**, **no elevation**, and following strict **tool vs controller separation**.

The intent is to:
- Maximize **small, reusable commands**
- Keep **controllers thin**
- Make **every layer testable in isolation**
- De-scope early to harden primitives before higher-level behavior

---

## DESIGN AXIOMS (REFERENCE)

- **Tools (cmdlets / functions)**  
  - Do *one thing*
  - Accept parameters
  - Output objects via pipeline
  - No assumptions about caller intent

- **Controllers (scripts)**  
  - Orchestrate tools
  - No real work
  - Handle flow, paths, and UX

---

# VCS HIDDEN DIRECTORY STRUCTURE (INITIAL PROPOSAL)

```text
.vcs/
├── HEAD                      # current ref (branch name or commit hash)
├── config.json               # repo configuration
├── index.json                # staging area manifest
├── objects/
│   ├── blobs/
│   │   └── <hash>            # raw file contents
│   ├── trees/
│   │   └── <hash>.json       # directory snapshot
│   └── commits/
│       └── <hash>.json       # commit metadata
├── refs/
│   ├── heads/
│   │   └── main              # branch pointers
│   └── tags/
└── logs/
    └── HEAD.log              # optional history
