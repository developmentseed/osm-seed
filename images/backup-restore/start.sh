#!/usr/bin/env bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD

# Upload files
cloudStorageOps() {
	local LOCAL_STATE_FILE=state.txt
	local filepath=$1
	local cloudpath=$2

	case "${CLOUDPROVIDER}" in
	aws)
		aws s3 cp ${filepath} ${AWS_S3_BUCKET}/${cloudpath}
		echo ${AWS_S3_BUCKET}/${cloudpath} >${LOCAL_STATE_FILE}
		aws s3 cp ${LOCAL_STATE_FILE} ${AWS_S3_BUCKET}/${BACKUP_CLOUD_FOLDER}/state.txt
		;;
	gcp)
		gsutil cp ${filepath} ${GCP_STORAGE_BUCKET}/${cloudpath}
		echo "${GCP_STORAGE_BUCKET}/${CLOUD_BACKUP_FILE}" >${LOCAL_STATE_FILE}
		gsutil cp ${LOCAL_STATE_FILE} ${GCP_STORAGE_BUCKET}/${BACKUP_CLOUD_FOLDER}/state.txt
		;;
	azure)
		az storage blob upload \
			--container-name ${AZURE_CONTAINER_NAME} \
			--file ${filepath} \
			--name ${cloudpath} \
			--output table
		echo "blob://${AZURE_STORAGE_ACCOUNT}/${AZURE_CONTAINER_NAME}/${CLOUD_BACKUP_FILE}" >${LOCAL_STATE_FILE}
		az storage blob upload \
			--container-name ${AZURE_CONTAINER_NAME} \
			--file ${LOCAL_STATE_FILE} \
			--name ${BACKUP_CLOUD_FOLDER}/state.txt \
			--output table
		;;
	esac
}

backupDB() {
	local LOCAL_BACKUP_FILE=${BACKUP_CLOUD_FILE}.sql.gz
	local CLOUD_BACKUP_FILE="${BACKUP_CLOUD_FOLDER}/${BACKUP_CLOUD_FILE}.sql.gz"
	if [ "$SET_DATE" == "true" ]; then
		local CURRENT_DATE=$(date '+%Y%m%d-%H%M')
		LOCAL_BACKUP_FILE="${BACKUP_CLOUD_FILE}-${CURRENT_DATE}.sql.gz"
		CLOUD_BACKUP_FILE="${BACKUP_CLOUD_FOLDER}/${BACKUP_CLOUD_FILE}-${CURRENT_DATE}.sql.gz"
	fi

	# Backup database with max compression
	pg_dump -h ${POSTGRES_HOST} -U ${POSTGRES_USER} ${POSTGRES_DB} | gzip -9 >${LOCAL_BACKUP_FILE}

	# Handle cloud storage based on the provider
	cloudStorageOps "${LOCAL_BACKUP_FILE}" "${CLOUD_BACKUP_FILE}"
}

restoreDB() {
	local RESTORE_FILE="backup.sql.gz"
	local flag=true

	while "$flag" = true; do
		pg_isready -h ${POSTGRES_HOST} -p 5432 >/dev/null 2>&2 || continue
		flag=false
		wget -O ${RESTORE_FILE} ${RESTORE_URL_FILE}
		gunzip <${RESTORE_FILE} | psql -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -d ${POSTGRES_DB}
		echo "Import data to ${POSTGRES_DB} has finished ..."
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
