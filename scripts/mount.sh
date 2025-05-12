#!/bin/bash

# Define the log file
LOGFILE="/tmp/mount_script.log"

# Log function to write to log file with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Start logging
log "Starting network check and mount process."

# Wait for network (up to 30s)
for i in {1..30}; do
    log "Attempting to ping 8.8.8.8 (Attempt $i)"
    if ping -c 1 8.8.8.8; then
        log "Network is up. Proceeding with systemctl restart."
        break
    else
        log "Network not reachable, retrying..."
    fi
    sleep 1
done

# Restart the mount service
log "Restarting the mnt-Media.mount service."
sudo systemctl restart mnt-Media.mount
log "Systemd service mnt-Media.mount restarted."

# End logging
log "Script execution completed."
