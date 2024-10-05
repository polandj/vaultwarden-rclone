#!/bin/bash

DATA_FOLDER=/data/
TEMP_DIR=/var/tmp/

# Make environment variables available
source /etc/environment

DATE_TIME=$(date ${BKUP_DT_FORMAT})
BACKUP_DIR=${TEMP_DIR}${DATE_TIME}/

echo "Backing up on ${DATE_TIME}"

# create a temporary directory
if [ -d "$BACKUP_DIR" ]; then
	rm -rdf "$BACKUP_DIR"
fi
mkdir "$BACKUP_DIR"

# Backup the Sqlite db
sqlite3 ${DATA_FOLDER}/db.sqlite3 ".backup '${BACKUP_DIR}db-dump.sqlite3'"
echo "Backup db done" 

# Backup the attachments dir
if [ -d "${DATA_FOLDER}attachments/" ]; then
	mkdir "$BACKUP_DIR"attachments/
	cp -r "${DATA_FOLDER}attachments/" "$BACKUP_DIR"
	echo "Backup attachments done"
else
	echo "Backup attachments skipped"
fi

# Backup the send dir
if [ -d "${DATA_FOLDER}sends/" ]; then
	mkdir "$BACKUP_DIR"sends/
	cp -r "${DATA_FOLDER}sends/" "$BACKUP_DIR"
	echo "Backup sends done"
else
	echo "Backup sends skipped"
fi

# Backup the config.json file
cp "${DATA_FOLDER}"*.json "$BACKUP_DIR"
echo "Backup json files done"

# Backup the rsa_key* files
cp "${DATA_FOLDER}"rsa_key.* "$BACKUP_DIR"
echo "Backup rsa keys done"

# Compress the temp folder (z: gzip, c: create, f: filename, C: move to temp_dir before compressing) and delete it
tar -zcf "${TEMP_DIR}${DATE_TIME}.tgz" -C "${BACKUP_DIR}" .
echo "Backup folder compressed"

# Setup the rclone endpoint (it's ok to do over and over)
#rclone config create ${BKUP_PROVIDER_NAME} ${BKUP_PROVIDER_TYPE} ${BKUP_PROVIDER_AUTH}
# Rclone to remote dest
rclone copy -L -q "${TEMP_DIR}${DATE_TIME}.tgz" ${BKUP_PROVIDER_NAME}:${BKUP_PROVIDER_DEST}

# Remove our work
if [ -d "$BACKUP_DIR" ]; then
        rm -rdf "$BACKUP_DIR"
fi
if [ -f "${TEMP_DIR}${DATE_TIME}.tgz" ]; then
	rm "${TEMP_DIR}${DATE_TIME}.tgz"
fi
