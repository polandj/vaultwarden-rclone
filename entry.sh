#!/bin/bash

CRONJOB_DIR=/etc/cron.d/
CRONJOB_FILE=backup_job

if [ -z ${BKUP_PROVIDER_AUTH+x} ]; then
	echo "BKUP_PROVIDER_AUTH needs to be set to authenticate with backup provider"; 
fi
if [ -z ${BKUP_PROVIDER_DEST+x} ]; then 
	echo "BKUP_PROVIDER_DEST needs to be set to specify destination path/bucket on backup provider"; 
fi

# Save the env variables for cron/backup script
printenv | grep 'BKUP_' >> /etc/environment

set -m

# Configure rclone
rclone config create ${BKUP_PROVIDER_NAME} ${BKUP_PROVIDER_TYPE} ${BKUP_PROVIDER_AUTH} 

# Spawn cron process in bg
cron &

#  Function to remove big numbers or double commas
format_cron_string() {
        # input string (ENV var), maximum value of the item
        IN_STR=$1
        MAX_NUM=$2

        # Check for *
        if [[ "$IN_STR" == "*" ]]; then
                OUTPUT="*"
        elif [[ "$IN_STR" =~ [\-0-9,]* ]]; then
                # Internal file separator = ,| read into array | from env variables
                IFS=',' read -ra ARRAY <<< "$IN_STR"

                OUTPUT=""

                # Check every element of the array
                for i in "${!ARRAY[@]}"; do
                        if [[ "${ARRAY[$i]}" == "" ]] || [[ "${ARRAY[$i]}" -gt "$MAX_NUM" ]] || [[ "${ARRAY[$i]}" -lt "0" ]]; then
                                unset ARRAY[$i]
                        else
                                OUTPUT=${OUTPUT}${ARRAY[$i]},
                        fi
                done

                # Remove last comma
                OUTPUT=${OUTPUT%,}
        else
                OUTPUT="*"
        fi

        if [[ "$OUTPUT" == "" ]]; then
                OUTPUT="*"
        fi

        # READ $OUTPUT
}

#  Format minute string
format_cron_string "$BKUP_AT_MIN" 60
MIN_STR="$OUTPUT"
format_cron_string "$BKUP_AT_HOUR" 24
HOUR_STR="$OUTPUT"

# Write the cron file.
echo "${MIN_STR}" "${HOUR_STR}" "* * * /./backup.sh" > "${CRONJOB_DIR}${CRONJOB_FILE}"
echo "# this line is needed for a valid cron file" >> "${CRONJOB_DIR}${CRONJOB_FILE}"

# Give the execution permission to the cron file
chmod 755 "${CRONJOB_DIR}${CRONJOB_FILE}"
# Add the cron job to root's crontab
crontab "${CRONJOB_DIR}${CRONJOB_FILE}"

# Launch start script, it prevents the container from exiting
./start.sh
