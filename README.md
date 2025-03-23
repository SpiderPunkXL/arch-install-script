# arch-install-script
Based on Christ Titus's Linux Utility server-setup.sh
Please go check out his project: https://github.com/ChrisTitusTech/linutil


## Automated Arch Linux Installer

### Step 1: Initial Setup WiFi (skip if hardwired)
- iwctl
- station wlan0 scan
- station wlan0 connect 'SSID'
- station wlan0 show

### Step 2: run script
- curl -L https://raw.githubusercontent.com/SpiderPunkXL/arch-install-script/refs/heads/main/arch-install.sh | bash

### Step 3: Use one of the following toolkit to install what you want
- bash -c "$(curl -fsSL https://xerolinux.xyz/script/xapi.sh)"
- curl -fsSL https://christitus.com/linux | sh

### Enjoy Your New Arch Linux Installation!


## References
- https://www.youtube.com/watch?v=PqGnlEmfYjM&t=639s
- https://www.youtube.com/watch?v=v0UPif52i5A
