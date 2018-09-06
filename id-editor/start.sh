#!/usr/bin/env bash
workdir="/app"
URLROOT=$SERVER_PROTOCOL':\/\/'$SERVER_URL
if [ -n "${OAUTH_SECRET:-}" ] && [ -n "${OAUTH_CONSUMER_KEY:-}" ] ; then
    sed -i -e 's/https:\/\/www.openstreetmap.org/'$URLROOT'/g' $workdir/modules/services/osm.js
    sed -i -e 's/5A043yRSEugj4DJ5TljuapfnrflWDte8jTOcWLlT/'$OAUTH_CONSUMER_KEY'/g' $workdir/modules/services/osm.js
    sed -i -e 's/aB3jKq1TRsCOUrfOIZ6oQMEDmv2ptV76PA54NGLL/'$OAUTH_SECRET'/g' $workdir/modules/services/osm.js
    npm start
else
    node info.js
fi