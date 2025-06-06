# unraid-duplicati-usb-backup

A simple Unraid script that automatically triggers a Duplicati backup job when a specific USB drive is mounted using the Unassigned Devices plugin. Useful for portable, offline, or rotation-based backups where the presence of a drive initiates the job.

## Features

- Triggers Duplicati backup automatically on USB drive mount
- Pulls web interface password from the running Docker container
- Uses Duplicati's API via `duplicati-server-util` to trigger jobs safely
- Supports Unraid notifications and optional system beep sounds for status
- Logs key events to syslog


## Requirements

- Unraid server with the Unassigned Devices plugin
- Developement branch of Duplicat [linuxserver/duplicati:development](https://hub.docker.com/r/linuxserver/duplicati) Docker container (required for `duplicati-server-util`)
- Preconfigured Duplicati backup job with correct source and destination paths
- Bind-mounted destination path for the USB device (e.g. `/mnt/disks/usb-backup`)
- Optional: `beep` command installed for audible notifications

## Configuration

Edit the script and set the following variables at the top:

```bash
CONTAINER_NAME="duplicati"       # Name of your Duplicati Docker container
BACKUP_NAME="ext-usb"            # Name of the Duplicati backup job to run
AUDIO_NOTIFICATION="yes"         # Set to "yes" to play beeps on success/failure
