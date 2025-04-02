# Arch Linux Automated Installation Script

This script is inspired by Chris Titus Tech's excellent `linutil` project (https://github.com/ChrisTitusTech/linutil).  



## Features

*   **Automated Installation:** Streamlines the Arch Linux installation process.
*   **DE Selection:** Offers a choice of popular Desktop Environments:
    *   GNOME
    *   KDE Plasma
    *   XFCE
    *   COSMIC (Alpha Quality - Use with Caution!)
*   **No DE Option:**  Allows for a minimal installation without a Desktop Environment.

## Installation Instructions

These instructions assume you are booted into an Arch Linux installation environment.

### Step 1: Initial Setup (Network)

Skip this step if you have a wired Ethernet connection.

1.  **Start the `iwctl` utility:**

    ```
    iwctl
    ```

2.  **Scan for available Wi-Fi networks:**

    ```
    station wlan0 scan
    ```

3.  **Connect to your Wi-Fi network.  Replace 'SSID' with your network name:**

    ```
    station wlan0 connect 'SSID'
    ```

4.  **Verify the connection:**

    ```
    station wlan0 show
    ```

    Ensure you have an IP address assigned.  If not, double-check your SSID and password.

### Step 2: Download and Run the Installation Script

1.  **Install Git:**

    ```
    pacman -Sy git --noconfirm
    ```

    The `--noconfirm` flag is added for fully automated installation.

2.  **Clone the repository:**

    ```
    git clone https://github.com/WizardBitter/arch-install-script.git
    ```

3.  **Navigate to the script directory:**

    ```
    cd arch-install-script
    ```

4.  **Make the script executable:**

    ```
    chmod +x arch-install.sh
    ```

5.  **Run the installation script:**

    ```
    ./arch-install.sh
    ```

    **Important:** Carefully read the script's prompts.  Choose your desired Desktop Environment (or no DE) when prompted.

6.  **(Important)** Once the script is finished running (indicated in the terminal), **reboot your system:**
    ```
    reboot
    ```

### Step 3: Post-Installation (Optional)

After rebooting into your new Arch Linux system, you can use the following toolkits to further customize your installation:

*   **XeroLinux Toolkit (XAPI):**

    ```
    bash -c "$(curl -fsSL https://xerolinux.xyz/script/xapi.sh)"
    ```

*   **Chris Titus Tech's Linux Utility (Linutil):**

    ```
    curl -fsSL https://christitus.com/linux | sh
    ```

### Step 4: Enjoy Your New Arch Linux Installation!

## Important Considerations

*   **Backup Your Data:** Before performing any system installation, it's crucial to back up your important data. This script automates the installation process, but data loss is always a possibility.
*   **Review the Script:** While this script is designed to simplify installation, it's always a good practice to review the script's contents before running it.  Understand what the script is doing to your system.
*   **COSMIC DE (Alpha):** The COSMIC desktop environment is under active development and may contain bugs or instability.  Use it at your own risk.
*   **Internet Connection:**  A stable internet connection is required during the installation process to download necessary packages.

## References

*   Chris Titus Tech's `linutil`: [https://www.youtube.com/watch?v=PqGnlEmfYjM&t=639s](https://www.youtube.com/watch?v=PqGnlEmfYjM&t=639s)
*   XeroLinux Toolkit: [https://www.youtube.com/watch?v=v0UPif52i5A](https://www.youtube.com/watch?v=v0UPif52i5A)

## Contributing

Contributions to this project are welcome!  Please fork the repository and submit a pull request with your changes.


