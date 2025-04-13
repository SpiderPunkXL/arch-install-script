# Arch Linux Automated Installation Script

This script, inspired by Chris Titus Tech's [linutil](https://github.com/ChrisTitusTech/linutil), automates the installation of Arch Linux with customizable desktop environment options.

## Features

- **Automated Installation**: Streamlines the Arch Linux setup process.
- **Desktop Environment Selection**:
  - GNOME
  - KDE Plasma
  - XFCE
  - COSMIC (Alpha – use with caution)
- **Minimal Installation Option**: Installs a base system without a desktop environment.
- **User-Friendly Prompts**: Guides users through configuration choices.

## Installation Instructions

These instructions assume you are booted into an Arch Linux live environment (e.g., from an ISO).

### Step 1: Set Up Network (If Needed)

If you have a wired Ethernet connection, skip to Step 2.

1. Start the `iwctl` utility:
   ```bash
   iwctl
   ```
2. Scan for Wi-Fi networks:
   ```bash
   station wlan0 scan
   ```
3. Connect to your Wi-Fi network (replace `SSID` with your network name):
   ```bash
   station wlan0 connect 'SSID'
   ```
4. Verify the connection:
   ```bash
   station wlan0 show
   ```
   - Confirm an IP address is assigned. If not, recheck your SSID and password.
   - Exit `iwctl` with `Ctrl+D`.

### Step 2: Download and Run the Installation Script

1. Install `git`:
   ```bash
   pacman -Sy git --noconfirm
   ```
   - The `--noconfirm` flag enables automated installation.

2. Clone the repository:
   ```bash
   git clone https://github.com/WizardBitter/arch-install-script.git
   ```

3. Navigate to the script directory:
   ```bash
   cd arch-install-script
   ```

4. Make the script executable:
   ```bash
   chmod +x arch-install.sh
   ```

5. Run the script:
   ```bash
   ./arch-install.sh
   ```
   - **Important**: Follow the prompts carefully to select your preferred desktop environment (or none).

6. Reboot your system after the script completes:
   ```bash
   reboot
   ```

### Step 3: Post-Installation (Optional)

After rebooting into your new Arch Linux system, enhance your setup with these tools:

- **Arch Linux Package Installer Script** (by WizardBitter):
  - Follow the README: [github.com/WizardBitter/arch-package-installer](https://github.com/WizardBitter/arch-package-installer)

- **XeroLinux Toolkit (XAPI)**:
   ```bash
   bash -c "$(curl -fsSL https://xerolinux.xyz/script/xapi.sh)"
   ```

- **Chris Titus Tech’s Linux Utility (linutil)**:
   ```bash
   curl -fsSL https://christitus.com/linux | sh
   ```

### Step 4: Enjoy Your Arch Linux System!

## Important Considerations

- **Backup Data**: Always back up critical data before installation. While this script is designed to be safe, data loss is possible.
- **Review the Script**: Examine `arch-install.sh` before running to understand its actions.
- **COSMIC DE (Alpha)**: COSMIC is under active development and may be unstable. Use at your own risk.
- **Internet Connection**: A stable internet connection is required to download packages.

## References

- Chris Titus Tech’s `linutil`: [YouTube Tutorial](https://www.youtube.com/watch?v=PqGnlEmfYjM&t=639s)
- XeroLinux Toolkit: [YouTube Tutorial](https://www.youtube.com/watch?v=v0UPif52i5A)

## Contributing

Contributions are welcome! Fork the repository and submit a pull request with your changes.
