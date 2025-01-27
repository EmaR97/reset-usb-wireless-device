#!/bin/bash

MAX_RETRIES=5
RETRY_DELAY=2
CONFIG_FILE="/etc/reset-wireless.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "ERROR: Config file not found. Exiting"
    exit 1
fi

timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

log_message() {
    local level=$1
    local message=$2

    case $level in
        "ERROR") color="\e[31m" ;;
        "WARN") color="\e[33m" ;;
        "INFO") color="\e[0m" ;;
        *) color="\e[0m" ;;
    esac

    echo -e "$(timestamp) [$level]: $color$message\e[0m" | sudo tee -a "$LOGFILE"
}

reset_usb_device() {
  for dev in /sys/bus/usb/devices/*/authorized; do
		log_message "INFO" "Disabling USB device. $dev"
		(echo '0' | sudo tee  "$dev") >> "$LOGFILE" 2>&1
		sleep 1
		log_message "INFO" "Enabling USB device."
		(echo '1' | sudo tee  "$dev") >> "$LOGFILE" 2>&1
  done
  if mycmd; then
      log_message "INFO" "USB reset successful."
  else
      log_message "ERROR" "USB reset failed. Check for errors."
  fi
}

find_ath9k_device() {
  for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
    log_message "INFO" "Attempt $attempt to find ath9k_htc device."

    USB_PATH=$(lsusb -t | grep -B 1 'Driver=ath9k_htc' | awk '
     /Bus/ {split($3, p, "."); split(p[1], p, "00"); bus=p[2]}
     /Port/ && NR==2 {split($3, p, ":"); split(p[1], p, "00"); port=p[2]}
     END {print bus "-" port}
    ')

    if [ -z "$USB_PATH" ] || [ "$USB_PATH" == "-" ]; then
       log_message "WARN" "ath9k_htc device not found. Retrying... (Attempt $attempt)"
       sleep $RETRY_DELAY
       if [ $attempt -ge $MAX_RETRIES ]; then
           log_message "ERROR" "Maximum retries reached. Rebooting the system."
						sudo systemctl reboot -r
           sleep 10
       fi
       continue
    fi

    DEVICE_PATH="/sys/bus/usb/devices/$USB_PATH"
    log_message "INFO" "ath9k_htc device found at $DEVICE_PATH."
    break
  done
}

log_message "INFO" "Script execution started."
log_message "INFO" "Checking internet connectivity."
if ! ping -c 1 -W 2 google.com > /dev/null; then
    log_message "WARN" "Ping failed."
    find_ath9k_device
    reset_usb_device
else
    log_message "INFO" "Connectivity check passed. No action needed."
fi
log_message "INFO" "Script execution completed."
