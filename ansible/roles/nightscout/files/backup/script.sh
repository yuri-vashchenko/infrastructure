#!/bin/sh

# --------------- [ SETTINGS ] ---------------

EXTENSION="tar.xz"
MONGO_DIR="/data"
BACKUPS_DIR="/backups"
BACKUP_TO_DIR="${MONGO_DIR}/dump"
BACKUP_FILENAME="${BACKUPS_DIR}/$(date +"%F_%H-%M-%S").${EXTENSION}"

# ------------------ [ BACKUP ] ------------------

# cleanup
rm -rf BACKUP_TO_DIR/*
# Back up database.
docker exec nightscout_mongo_1 mongodump --out "${BACKUP_TO_DIR}"

# Compress to a single file
tar -Jcf ${BACKUP_FILENAME} ${BACKUP_TO_DIR} 2>/dev/null

OUTPUT="${OUTPUT}New backup created"

# ------------------ [ DELETE ] ------------------

if [ -n "$DELETE_AFTER" ] && [ "$DELETE_AFTER" -gt 0 ]; then
    cd "${BACKUPS_DIR}"

    # Find all archives older than x days, store them in a variable, delete them.
    TO_DELETE=$(find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER)
    find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER -exec rm -f {} \;

    OUTPUT="${OUTPUT}, $([ ! -z "$TO_DELETE" ] \
                       && echo "deleted $(echo "$TO_DELETE" | wc -l) archives older than ${DELETE_AFTER} days" \
                       || echo "no archives older than ${DELETE_AFTER} days to delete")"
fi

# ------------------ [ EXIT ] ------------------

echo "[$(date +"%F %r")] ${OUTPUT}."
