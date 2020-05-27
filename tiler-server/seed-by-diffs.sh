#!/bin/bash
set -a
set +a

workDir=/mnt/data

expire_dir=$workDir/imposm/imposm3_expire_dir
mkdir -p $expire_dir

# This will be essentially treated as a pidfile
queued_jobs=$workDir/imposm/in_progress.list
# Output of seeded
completed_jobs=$workDir/imposm/completed.list

# Directory to place the worked expiry lists
completed_dir=$workDir/imposm/imposm3_expire_purged
mkdir -p $completed_dir


# List files in expire_dir
imp_list=`find $expire_dir -name '*.tiles' -type f`

for f in $imp_list; do
    echo "$f" >> $queued_jobs
done

# Sort the files and set unique rows
if [ -f $queued_jobs ] ; then
    sort -u $queued_jobs > $workDir/imposm/tmp.list && mv $workDir/imposm/tmp.list $queued_jobs
fi

for f in $imp_list; do
    echo "seeding from $f"
    # Read each line on the tiles file
    while IFS= read -r tile
    do
        bounds="$(python tile2bounds.py $tile)"
        echo tegola cache purge \
        --config=/opt/tegola_config/config.toml \
        --min-zoom=0 --max-zoom=20 \
        --bounds=$bounds \
        tile-name=$tile
        
        tegola cache purge \
        --config=/opt/tegola_config/config.toml \
        --min-zoom=0 --max-zoom=20 \
        --bounds=$bounds \
        tile-name=$tile
        err=$?
        if [[ $err != "0" ]]; then
            #error
            echo "tegola exited with error code $err"
            # rm $queued_jobs
            exit
        fi
    done < "$f"
    echo "$f" >> $completed_jobs
    mv $f $completed_dir
done

if [ -f $queued_jobs ] ; then
    echo "finished seeding"
    rm $queued_jobs
fi
