#!/bin/bash
# # SCRIPT FR USE WITH UNSASSIGNED DEVICES PLUGIN & DUPLICATI# # # # # # # # # # # 
# #                            BY SPACEINVADERONE             # # # # # # # # # # 
# # # # # # # # # #  USER CONFIGURATION  # # # # # # # # # # # # # # # # # # # # # 

CONTAINER_NAME="duplicati"               # Duplicati Docker container name
BACKUP_NAME="ext-usb"                    # Duplicati backup job name
DUPLICATI_PASSWORD=""                    # Leave blank to auto-fetch from container
AUDIO_NOTIFICATION="yes"                 # Set to "yes" to enable audio beep music notifications

# # # # # # # #  DO NOT CHANGE BELOW THIS LINE # # # # # # # # # # # # # # # # # # 
# audio notify
play_audio() {
  local result="$1"
  [[ "$AUDIO_NOTIFICATION" != "yes" ]] && return

  if [[ "$result" == "success" ]]; then
    beep -f 130 -l 100 -n -f 262 -l 100 -n -f 330 -l 100 -n -f 392 -l 100 -n -f 523 -l 100 -n -f 660 -l 100 -n -f 784 -l 300 -n -f 660 -l 300 -n -f 146 -l 100 -n -f 262 -l 100 -n -f 311 -l 100 -n -f 415 -l 100 -n -f 523 -l 100 -n -f 622 -l 100 -n -f 831 -l 300 -n -f 622 -l 300 -n -f 155 -l 100 -n -f 294 -l 100 -n -f 349 -l 100 -n -f 466 -l 100 -n -f 588 -l 100 -n -f 699 -l 100 -n -f 933 -l 300 -n -f 933 -l 100 -n -f 933 -l 100 -n -f 933 -l 100 -n -f 1047 -l 400
  else
    beep -l 350 -f 392 -D 100 -n -l 350 -f 392 -D 100 -n -l 350 -f 392 -D 100 -n -l 250 -f 311.1 -D 100 -n -l 25 -f 466.2 -D 100 -n -l 350 -f 392 -D 100 -n -l 250 -f 311.1 -D 100 -n -l 25 -f 466.2 -D 100 -n -l 700 -f 392 -D 100 -n -l 350 -f 587.32 -D 100 -n -l 350 -f 587.32 -D 100 -n -l 350 -f 587.32 -D 100 -n -l 250 -f 622.26 -D 100 -n -l 25 -f 466.2 -D 100 -n -l 350 -f 369.99 -D 100 -n -l 250 -f 311.1 -D 100 -n -l 25 -f 466.2 -D 100 -n -l 700 -f 392 -D 100 -n -l 350 -f 784 -D 100 -n -l 250 -f 392 -D 100 -n -l 25 -f 392 -D 100 -n -l 350 -f 784 -D 100 -n -l 250 -f 739.98 -D 100 -n -l 25 -f 698.46 -D 100 -n -l 25 -f 659.26 -D 100 -n -l 25 -f 622.26 -D 100 -n -l 50 -f 659.26 -D 400 -n -l 25 -f 415.3 -D 200 -n -l 350 -f 554.36 -D 100 -n -l 250 -f 523.25 -D 100 -n -l 25 -f 493.88 -D 100 -n -l 25 -f 466.16 -D 100 -n -l 25 -f 440 -D 100 -n -l 50 -f 466.16 -D 400 -n -l 25 -f 311.13 -D 200 -n -l 350 -f 369.99 -D 100 -n -l 250 -f 311.13 -D 100 -n -l 25 -f 392 -D 100 -n -l 350 -f 466.16 -D 100 -n -l 250 -f 392 -D 100 -n -l 25 -f 466.16 -D 100 -n -l 700 -f 587.32
  fi
}

# get duplicati webui pass from docker variable
get_password() {
  if [[ -z "$DUPLICATI_PASSWORD" ]]; then
    DUPLICATI_PASSWORD=$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$CONTAINER_NAME" \
      | grep -i '^DUPLICATI__WEBSERVICE_PASSWORD=' \
      | cut -d '=' -f2-)
  fi

  if [[ -z "$DUPLICATI_PASSWORD" ]]; then
    logger "[Duplicati USB Trigger] ERROR: Missing password"
    /usr/local/emhttp/webGui/scripts/notify -e "Duplicati USB Backup" -s "Backup Error" -d "Missing password" -i "alert"
    play_audio "fail"
    exit 1
  fi
}

# login to duplicati
login_to_server() {
  docker exec -i "$CONTAINER_NAME" /app/duplicati/duplicati-server-util login \
    --password="$DUPLICATI_PASSWORD" \
    --hosturl=http://localhost:8200 > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    logger "[Duplicati USB Trigger] ERROR: API login failed"
    /usr/local/emhttp/webGui/scripts/notify -e "Duplicati USB Backup" -s "Login Failed" -d "Could not login to API" -i "alert"
    play_audio "fail"
    exit 1
  fi
}

# run the backup
run_backup() {
  /usr/local/emhttp/webGui/scripts/notify -e "Duplicati USB Backup" -s "Backup Started" -d "Job '$BACKUP_NAME' running" -i "normal"
  logger "[Duplicati USB Trigger] Running job: $BACKUP_NAME"

  docker exec "$CONTAINER_NAME" /app/duplicati/duplicati-server-util run "$BACKUP_NAME"
  local RESULT=$?

  if [[ $RESULT -eq 0 ]]; then
    /usr/local/emhttp/webGui/scripts/notify -e "Duplicati USB Backup" -s "Backup Complete" -d "Job '$BACKUP_NAME' completed" -i "normal"
    logger "[Duplicati USB Trigger] Job completed successfully"
    play_audio "success"
  else
    /usr/local/emhttp/webGui/scripts/notify -e "Duplicati USB Backup" -s "Backup Failed" -d "Job '$BACKUP_NAME' failed" -i "alert"
    logger "[Duplicati USB Trigger] Job failed"
    play_audio "fail"
    exit 1
  fi
}

# run if mounted only
if [[ "$ACTION" != "ADD" ]]; then
  logger "[Duplicati USB Trigger] Skipping non-mount action: '$ACTION'"
  exit 0
fi

get_password
login_to_server
run_backup
