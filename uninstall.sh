#!/bin/bash

# Config file
CONFIG_FILE="/etc/reset-wireless.conf"
LOGROTATE_CONF="/etc/logrotate.d/reset-wireless"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found. Aborting uninstallation."
    exit 1
fi

# Read the configuration file
source "$CONFIG_FILE"

# Validate the variables
if [ -z "$LOGFILE" ] || [ -z "$SCRIPT_PATH" ]; then
    echo "LOGFILE or SCRIPT_PATH not defined in the config file. Aborting uninstallation."
    exit 1
fi

# Remove the cron job
(crontab -l | grep -v "$SCRIPT_PATH") | crontab -

# Remove the script file
if [ -f "$SCRIPT_PATH" ]; then
    sudo rm "$SCRIPT_PATH"
    echo "Removed script at $SCRIPT_PATH."
else
    echo "Script not found at $SCRIPT_PATH."
fi

# Remove the log rotation configuration
if [ -f "$LOGROTATE_CONF" ]; then
    sudo rm "$LOGROTATE_CONF"
    echo "Removed log rotation configuration at $LOGROTATE_CONF."
else
    echo "Log rotation configuration not found at $LOGROTATE_CONF."
fi

# Confirmation message
echo "Uninstallation complete. All associated files and configurations have been removed."

