#!/usr/bin/env bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD

# osmdbt publishes the minute replication stream. Its state.txt has the current
# sequenceNumber, which tracks the database WAL. Read it at backup time so the
# dump knows its replication position. Default points at OSM; each deployment
# sets its own URL via env (OHM uses its own stream).
export MINUTE_REPLICATION_URL="${MINUTE_REPLICATION_URL:-https://planet.openstreetmap.org/replication/minute}"
# Upload files
cloudStorageOps() {
	local LOCAL_STATE_FILE=state.txt
	local filepath=$1
	local cloudpath=$2

	case "${CLOUDPROVIDER}" in
	aws)
		aws s3 cp ${filepath} s3://${AWS_S3_BUCKET}/${cloudpath}
		echo s3://${AWS_S3_BUCKET}/${cloudpath} >${LOCAL_STATE_FILE}
		aws s3 cp ${LOCAL_STATE_FILE} s3://${AWS_S3_BUCKET}/${BACKUP_CLOUD_FOLDER}/state.txt
		;;
	esac
}

backupDB() {
    local BASE="${BACKUP_CLOUD_FILE}"
    if [ "$SET_DATE_AT_NAME" == "true" ]; then
        local CURRENT_DATE
        CURRENT_DATE=$(date '+%Y%m%d-%H%M')
        BASE="${BACKUP_CLOUD_FILE}-${CURRENT_DATE}"
    fi
    local LOCAL_BACKUP_FILE="${BASE}.dump"
    local LOCAL_BACKUP_FILE_GZIP="${BASE}.dump.gz"
    local CLOUD_BACKUP_FILE="${BACKUP_CLOUD_FOLDER}/${BASE}.dump.gz"
    local LOCAL_SEQNO_FILE="${BASE}.state.txt"
    local CLOUD_SEQNO_FILE="${BACKUP_CLOUD_FOLDER}/${BASE}.state.txt"

    # Read the replication position before the snapshot. Doing it first keeps the
    # seqno at or behind the dump's data, which is the safe side: a consumer
    # replays a few extra diffs instead of skipping some. The seqno comes from the
    # osmdbt minute state, which tracks the WAL.
    echo "Capturing replication state from ${MINUTE_REPLICATION_URL}/state.txt"
    if wget -qO "${LOCAL_SEQNO_FILE}" "${MINUTE_REPLICATION_URL}/state.txt"; then
        echo "Replication state captured for this dump:"
        cat "${LOCAL_SEQNO_FILE}"
    else
        echo "WARNING: could not fetch replication state; dump will have no seqno sidecar"
        rm -f "${LOCAL_SEQNO_FILE}"
    fi

    # Backup database with pg_dump custom format (-Fc) + gzip
    echo "Backing up DB ${POSTGRES_DB} into ${LOCAL_BACKUP_FILE_GZIP}"
    pg_dump -h "${POSTGRES_HOST}" -U "${POSTGRES_USER}" -Fc "${POSTGRES_DB}" | gzip -9 > "${LOCAL_BACKUP_FILE}.gz"
    cloudStorageOps "${LOCAL_BACKUP_FILE_GZIP}" "${CLOUD_BACKUP_FILE}"

    # Upload the seqno sidecar next to the dump, so planet-dump can read the exact
    # replication position for this dump instead of guessing it from a timestamp.
    if [ -f "${LOCAL_SEQNO_FILE}" ]; then
        echo "Uploading seqno sidecar to s3://${AWS_S3_BUCKET}/${CLOUD_SEQNO_FILE}"
        aws s3 cp "${LOCAL_SEQNO_FILE}" "s3://${AWS_S3_BUCKET}/${CLOUD_SEQNO_FILE}"
    fi
}

restoreDB() {
	local CURRENT_DATE=$(date '+%Y%m%d-%H%M')
	local RESTORE_FILE="backup.dump"
	local LOG_RESULT_FILE="restore_results-${CURRENT_DATE}.log"
	local flag=true

	while "$flag" = true; do
		pg_isready -h ${POSTGRES_HOST} -p 5432 >/dev/null 2>&2 || continue
		flag=false
		wget -O ${RESTORE_FILE} ${RESTORE_URL_FILE}
		echo "Restoring ${RESTORE_URL_FILE} in ${POSTGRES_DB}"
		pg_restore -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -d ${POSTGRES_DB} --create --no-owner ${RESTORE_FILE} | tee ${LOG_RESULT_FILE}
		# aws s3 cp ${LOG_RESULT_FILE} s3://${AWS_S3_BUCKET}/${LOG_RESULT_FILE}
		echo "Import data to ${POSTGRES_DB} has finished ..."
	done
}

delete_old_s3_files() {
	# Use RETENTION_DAYS from environment variable or default to 30 days
	if [ -z "${RETENTION_DAYS}" ]; then
		DAYS_AGO=30
	else
		DAYS_AGO="${RETENTION_DAYS}"
	fi

	echo "Files older than $DAYS_AGO days will be deleted."
	echo "Processing s3://${AWS_S3_BUCKET}/${BACKUP_CLOUD_FOLDER}/"
	TARGET_DATE=$(date -d "${DAYS_AGO} days ago" +%Y-%m-%d)
	aws s3 ls "s3://${AWS_S3_BUCKET}/${BACKUP_CLOUD_FOLDER}/" --recursive | while read -r line; do
		FILE_DATE=$(echo "$line" | awk '{print $1}')
		FILE_PATH=$(echo "$line" | awk '{print $4}')
		if [[ "$FILE_DATE" < "$TARGET_DATE" && ! -z "$FILE_PATH" ]]; then
			echo "Deleting ${FILE_PATH} which was modified on ${FILE_DATE}"
			aws s3 rm "s3://${AWS_S3_BUCKET}/${FILE_PATH}"
		fi
	done
}

# Main logic
case "${DB_ACTION}" in
backup)
	backupDB
	;;
restore)
	restoreDB
	;;
*)
	echo "Unknown action: ${DB_ACTION}"
	exit 1
	;;
esac

# Check for the CLEAN_BACKUPS var
if [ "$CLEANUP_BACKUPS" == "true" ]; then
	delete_old_s3_files
else
	echo "CLEANUP_BACKUPS is not set to true. Skipping deletion."
fi
