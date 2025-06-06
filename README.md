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

## Password Handling

There is no need to hardcode the password; it will be pulled automatically from the container’s environment variable:  
`DUPLICATI__WEBSERVICE_PASSWORD`.
```
---

## Usage

1. Mount your USB device once and confirm its mountpoint (e.g. `/mnt/disks/usb-backup`).
2. Create a backup job in the Duplicati web UI   
3. Set that path as the backup destination inside Duplicati.  
4. Save this script in Unassigned devices addition settings  
5. When the drive is plugged in and mounted, the backup will start automatically.

---

## Notes

- This script checks for the mount event using the `$ACTION` variable provided by Unassigned Devices.  
- It only runs on `ADD` (mount) and will skip `UNMOUNT`, `REMOVE`, etc.  
- Be sure the Duplicati job’s source and destination paths match the USB device's mountpoint.  
- The container must use the `:development` tag or newer, as `duplicati-server-util` is not available in stable releases.

---

## Troubleshooting

- If you do not hear any beep audio you will need a beep speaker in yor server
- If the backup fails, check the syslog for error messages from the script or Duplicati logs.  
- Ensure `/app/duplicati/duplicati-server-util` exists and runs without error from inside the container. Currently you must be runnig dev version of Duplicati

---

## License

MIT
