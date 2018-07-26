#!/usr/bin/env bash
workdir="/app"
URLROOT='http:\/\/'$SERVER_URL
# OAUTH_CONSUMER_KEY='ENNIKpicSeIj14r81bOJCzcrR9xuVzaVAn1IX6FI'
# OAUTH_SECRET='ZaEYPnTiICQHf78biNX07383MtANqCv7kHWBp4y6'
if [[ -v "$URLROOT" ]] && [[ -v "$OAUTH_CONSUMER_KEY" ]] && [[ -v "$OAUTH_SECRET" ]];then 
    sed -i -e 's/https:\/\/www.openstreetmap.org/'$URLROOT'/g' $workdir/modules/services/osm.js
    sed -i -e 's/5A043yRSEugj4DJ5TljuapfnrflWDte8jTOcWLlT/'$OAUTH_CONSUMER_KEY'/g' $workdir/modules/services/osm.js
    sed -i -e 's/aB3jKq1TRsCOUrfOIZ6oQMEDmv2ptV76PA54NGLL/'$OAUTH_SECRET'/g' $workdir/modules/services/osm.js
    npm start
else
    node info.js
fi