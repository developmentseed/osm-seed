#!/usr/bin/env bash
WORKDIR=/usr/src/app
DATADIR=${TAGINFO_DATA_DIR:-/usr/src/app/data}
mkdir -p "$DATADIR"

if [ "$(id -u)" = "0" ]; then
    chmod 777 "$DATADIR" 2>/dev/null || true
fi

download_db_files() {
    [ -z "$TAGINFO_DB_BASE_URL" ] && return 0
    base_url="${TAGINFO_DB_BASE_URL%/}"
    db_files=(projects-cache.db selection.db taginfo-chronology.db taginfo-db.db
              taginfo-history.db taginfo-languages.db taginfo-master.db
              taginfo-projects.db taginfo-wiki.db taginfo-wikidata.db taginfo-sw.db)

    echo "Downloading DB files from $base_url to $DATADIR"
    for db in "${db_files[@]}"; do
        if [ -f "$DATADIR/$db" ]; then
            echo "  Skip $db (exists)"
        else
            echo "Downloading ${base_url}/${db}"
            wget -q -O "$DATADIR/$db" --no-check-certificate "${base_url}/${db}" || echo "  Failed $db"
        fi
    done
    [ "$(id -u)" = "0" ] && chown -R taginfo:taginfo "$DATADIR" 2>/dev/null || true
}

cd "$WORKDIR/taginfo/web" || exit 1
download_db_files
exec gosu taginfo ruby taginfo.rb -o 0.0.0.0 -p 4567
