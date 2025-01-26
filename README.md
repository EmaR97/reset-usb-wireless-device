# **Automated Reset for USB Wireless Devices**

Addressing connectivity issues encountered by wireless USB devices using the `ath9k_htc` driver. These issues arise due
to hardware or driver faults, causing network drops or the device to become unresponsive. The solution automates the
process of detecting and resetting the device without requiring manual intervention, ensuring network functionality in
automated or remote setups.

---

## **Problem Description**

MY wireless USB devices using the `ath9k_htc` driver encounter the following symptoms after prolonged system uptime:

- Network drops.
- Device stops responding to system commands.

I resolved the issue is often by physically unplugging and reinserting the USB device. However, this is impractical for
remote or automated systems.

### Example of the Problem:

Below are typical log entries when the issue occurs:

```plaintext
[58567.0516951] ath: phy2: Failed to wakeup in 500us
[63353.087545] ath: phy3: Chip reset failed
[63353.0876511] ath: phy3: Unable to set channel
```

---

## **Solution**

This project provides a Bash script that:

- Monitors network connectivity.
- Dynamically identifies the USB path of the faulty `ath9k_htc` device.
- Automatically resets the device by disabling and re-enabling it programmatically.
- Logs all operations and errors for monitoring and debugging purposes.

---

## **Features**

- **Automatic Device Reset**: Detects and resets unresponsive `ath9k_htc` devices without manual intervention.
- **Internet Connectivity Check**: Ensures active network connectivity.
- **Logging**: Captures detailed logs for troubleshooting.
- **Configurable Settings**: Customize log file locations and script paths.
- **Log Rotation**: Automatically manages log file size through `logrotate`.
- **Cron Job Integration**: Periodically checks and resets the device, ensuring long-term reliability.

---

## **Setup and Installation**

### Prerequisites

1. A Linux system with `bash` installed.
2. Root or sudo privileges to modify USB settings, cron jobs, and log files.

### Installation Steps

1. Clone the repository or copy the script files to your local system.
   ```bash
   git clone https://github.com/EmaR97/reset-usb-wireless-device.git
   ```
2. Navigate to the project directory:
   ```bash
   cd reset-usb-wireless-device
   ```
3. Enable script execution if needed

   ```bash
   chmod +x install.sh
   chmod +x uninstall.sh
   chmod +x reset-wireless.sh
   ```

4. Run the installation script:
   ```bash
   ./install.sh 
   ```
   or the following if you want to specify different installation folders:
   ```bash
   ./install.sh [LOGFILE] [SCRIPT_PATH]
   ```
    - **LOGFILE**: (Optional) Path to the log file. Default: `/var/log/reset-wireless.log`.
    - **SCRIPT_PATH**: (Optional) Path where the main script will be installed. Default:
      `/usr/local/bin/reset-wireless.sh`.

5. The script will:
    - Configure periodic checks using a cron job (runs every 5 minutes by default).
    - Create a log file and configure log rotation.
    - Copy the main script to the specified directory.

---

## **Usage**

The script runs automatically as a cron job every 5 minutes. To test it manually:

```bash
sudo /usr/local/bin/reset-wireless.sh
```

### Configuration

The configuration file (`/etc/reset-wireless.conf`) stores customizable settings:

- **LOGFILE**: Path to the log file.
- **SCRIPT_PATH**: Path to the main script.

To edit the configuration:

```bash
sudo nano /etc/reset-wireless.conf
```

---

## **Uninstallation**

To completely remove the script and its associated files:

1. Run the uninstallation script:
   ```bash
   ./uninstall.sh
   ```
2. This will:
    - Remove the cron job.
    - Delete the script and log rotation configuration.
    - Clean up the log file and configuration file.

---

## **Logging and Debugging**

The script logs all activity to the configured log file (default: `/var/log/reset-wireless.log`). Example log entry:

```plaintext
2025-01-25 14:23:45 [INFO]: Script execution started.
2025-01-25 14:23:46 [WARN]: Ping failed.
2025-01-25 14:23:47 [INFO]: ath9k_htc device found at /sys/bus/usb/devices/2-1.
2025-01-25 14:23:48 [INFO]: USB reset successful.
```

Logs are automatically rotated weekly with up to 4 backups retained.

---

## **How It Works**

1. **Internet Connectivity Check**: The script pings a reliable host (e.g., `google.com`) to verify connectivity.
2. **Device Detection**: Uses `lsusb` and system paths to identify the USB path of the `ath9k_htc` device.
3. **Device Reset**: Disables and re-enables the USB device via the `/sys/bus/usb/devices` interface.
4. **Error Handling**: Retries up to 5 times before triggering a system reboot if the issue persists.

