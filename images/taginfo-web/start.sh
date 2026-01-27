#!/usr/bin/env bash
WORKDIR=/usr/src/app
DATADIR=${TAGINFO_DATA_DIR:-/usr/src/app/data}
mkdir -p "$DATADIR"

download_db_files() {
    [ -z "$TAGINFO_DB_BASE_URL" ] && return 0
    base_url="${TAGINFO_DB_BASE_URL%/}/"
    db_files=(projects-cache.db selection.db taginfo-chronology.db taginfo-db.db
              taginfo-history.db taginfo-languages.db taginfo-master.db
              taginfo-projects.db taginfo-wiki.db taginfo-wikidata.db taginfo-sw.db)

    echo "Downloading DB files from $base_url to $DATADIR"
    for db in "${db_files[@]}"; do
        if [ -f "$DATADIR/$db" ]; then
            echo "  Skip $db (exists)"
        else
            echo "  wget $db"
            wget -q -O "$DATADIR/$db" --no-check-certificate "${base_url}${db}" 2>/dev/null || true
        fi
    done
}

cd "$WORKDIR/taginfo/web" || exit 1
download_db_files
exec ruby taginfo.rb -o 0.0.0.0 -p 4567
