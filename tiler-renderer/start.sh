#!/bin/bash
export PGHOST=$POSTGRES_TILER_HOST
export PGPORT=$POSTGRES_TILER_PORT
export PGDATABASE=$POSTGRES_TILER_DB
export PGUSER=$POSTGRES_TILER_USER
export PGPASSWORD=$POSTGRES_TILER_PASSWORD
expiredDirectory=$EXPIRED_DIR

function renderData () {
    while true; do    
    if [ -f $expiredDirectory/state.txt ]; then
        # work only if sequenceNumber exists
        sequenceNumber=$(cat $expiredDirectory/state.txt | grep sequenceNumber | cut -d "=" -f2)
        if [ -n "$sequenceNumber" ]; then
            # reset the currentlyExpired file
            > $expiredDirectory/currentlyExpired.list
            
            # get the last rendered change
            lastRendered=$(cat $expiredDirectory/state.txt | grep lastRendered | cut -d "=" -f2)
            if [ -z "$lastRendered" ]; then
                lastRendered=-1
            fi

            # populate the currentlyExpired file with expired tiles
            for (( i=($lastRendered+1); i <= $sequenceNumber; ++i ))
            do
                dir1=$(parseIntegerToDirectoryNumber "$(($i/1000000))")
                dir2=$(parseIntegerToDirectoryNumber "$(($i/1000))")
                state=$(parseIntegerToDirectoryNumber "$(($i%1000))")
                # TODO: find the right change permissions
                chmod 777 $expiredDirectory/$dir1/$dir2/$state-expire.list
                cat $expiredDirectory/$dir1/$dir2/$state-expire.list >> $expiredDirectory/currentlyExpired.list
            done

            # remove duplicates
            sort $expiredDirectory/currentlyExpired.list | uniq -u

            # render the expired tiles
            cat $expiredDirectory/currentlyExpired.list | /src/mod_tile/render_expired --map=osm --min-zoom=8 --touch-from=8 >/dev/null

            # modify state.txt
            if grep -q "lastRendered" $expiredDirectory/state.txt
                then
                    sed -i -e 's/.*lastRendered=.*/lastRendered='$sequenceNumber'/g' $expiredDirectory/state.txt
                else
                    echo "lastRendered=$sequenceNumber" >> $expiredDirectory/state.txt
            fi
        fi
    fi
        sleep $RENDER_EXPIRED_TILES_INTERVAL
    done
}

function parseIntegerToDirectoryNumber () {
    echo $( printf '%03d' $1)
}

function getExternalData () {
    echo "getting external data"
    PGPASSWORD=$POSTGRES_TILER_PASSWORD /src/openstreetmap-carto/scripts/get-external-data.py -H $POSTGRES_TILER_HOST -d $POSTGRES_TILER_DB -p 5432 -U $POSTGRES_TILER_USER -c /src/openstreetmap-carto/external-data.yml
}

getExternalData
service apache2 start
# service apache2 reload
# service apache2 reload
renderd -c /usr/local/etc/renderd.conf
renderData
