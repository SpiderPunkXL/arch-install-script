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
- pacman -Sy git
- git clone https://github.com/SpiderPunkXL/arch-install-script.git
- cd arch-install-script
- chmod +x arch-install.sh
- ./archinstall.sh
- reboot (once script is finished running)

### Step 3: Use one of the following toolkit to install what you want
- bash -c "$(curl -fsSL https://xerolinux.xyz/script/xapi.sh)"
- curl -fsSL https://christitus.com/linux | sh

### Enjoy Your New Arch Linux Installation!

## References
- https://www.youtube.com/watch?v=PqGnlEmfYjM&t=639s (CT's linutil)
- https://www.youtube.com/watch?v=v0UPif52i5A (Xero's Toolkit)
