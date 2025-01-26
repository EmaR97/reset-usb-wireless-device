#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR" || { echo "Unable to change folder. Exiting"; exit 1; }

# Default values
DEFAULT_LOGFILE="/var/log/reset-wireless.log"
DEFAULT_SCRIPT_PATH="/usr/local/bin/reset-wireless.sh"
TEMPLATE_PATH="reset-wireless.sh"  # Path to the template file
CONFIG_FILE="/etc/reset-wireless.conf"  # Path to the config file
LOGROTATE_CONF="/etc/logrotate.d/reset-wireless"

# Accept parameters or use default values
LOGFILE="${1:-$DEFAULT_LOGFILE}"
SCRIPT_PATH="${2:-$DEFAULT_SCRIPT_PATH}"

echo "Using LOGFILE: $LOGFILE"
echo "Using SCRIPT_PATH: $SCRIPT_PATH"

# Delete the generated files if there's an error
cleanup() {
    echo "Cleaning up generated files..."
    sudo rm -f "$CONFIG_FILE"
    sudo rm -f "$SCRIPT_PATH"
    sudo rm -f "$LOGROTATE_CONF"
}

# Create or update the config file with log file and script path
echo "LOGFILE=$LOGFILE" | sudo tee "$CONFIG_FILE" > /dev/null || { cleanup; exit 1; }
echo "SCRIPT_PATH=$SCRIPT_PATH" | sudo tee -a "$CONFIG_FILE" > /dev/null || { cleanup; exit 1; }

# Copy the script content from the template file
if [ -f "$TEMPLATE_PATH" ]; then
    sudo cp "$TEMPLATE_PATH" "$SCRIPT_PATH" || { cleanup; exit 1; }
else
    echo "Template file not found. Aborting installation."
    cleanup
    exit 1
fi

# Update the LOGFILE in the copied script if necessary
if [ "$LOGFILE" != "$DEFAULT_LOGFILE" ]; then
    sudo sed -i "s|/var/log/reset-wireless.log|$LOGFILE|g" "$SCRIPT_PATH" || { cleanup; exit 1; }
    echo "LOGFILE inside the script updated to: $LOGFILE"
fi

# Make the script executable
sudo chmod +x "$SCRIPT_PATH" || { cleanup; exit 1; }

# Create log file and set proper permissions
sudo touch "$LOGFILE" || { cleanup; exit 1; }
sudo chmod 664 "$LOGFILE" || { cleanup; exit 1; }
sudo chown "$USER":syslog "$LOGFILE" || { cleanup; exit 1; }

# Set up log rotation
sudo bash -c "cat << EOF > $LOGROTATE_CONF
$LOGFILE {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 664 root syslog
}
EOF" || { cleanup; exit 1; }

# Add script to cron for periodic checks (every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * $SCRIPT_PATH") | crontab - || { cleanup; exit 1; }

# Confirmation message
echo "Install complete. The script will now run every 5 minutes to monitor the ath9k_htc device and reset it if necessary."
