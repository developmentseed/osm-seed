#!/usr/bin/env node
const { Client } = require('pg');
const moment = require('moment');
const client = new Client({
    user: process.env.POSTGRES_USER,
    host: process.env.POSTGRES_HOST,
    database: process.env.POSTGRES_DB,
    password: process.env.POSTGRES_PASSWORD,
    port: 5432,
});
client.connect();
// Start here
insertUser(function (idUser) {
    inserAppp(idUser, function (resp) {
        console.log(JSON.stringify(resp));
        client.end();
    });
});

function insertUser(cb) {
    const query = `INSERT INTO public.users(
        id,
         email, 
         creation_time, 
         pass_crypt, 
         display_name,
         data_public,
         pass_salt ,
         email_valid,
         status,
         terms_seen) 
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9, $10);`;
    client.query('SELECT count(*) as count FROM public.users;')
        .then(res => {
            const id = parseInt(res.rows[0].count) + 1;
            const email = 'osmseed_ideditor@developementseed.com';
            const creation_time = moment(new Date(), 'YYYY-MM-DD HH:MM:SS');
            const pass_crypt = 'WeOf9adJmorOIBW+2+AW/WtImJgw2S6+Zs+1rec8HcA=';
            const display_name = 'osmseed_ideditor';
            const data_public = true;
            const pass_salt = 'sha512!10000!3GUmzkwhkiirzKpLx/cHr58Db115vyNtKwDcavggb98=';
            const email_valid = true;
            const status = 'active';
            const terms_seen = true
            const values = [id, email, creation_time, pass_crypt, display_name, data_public, pass_salt, email_valid, status, terms_seen];
            client.query(query, values)
                // .then(result => console.log(result))
                .catch(e => console.error(e.stack))
                .then(() => cb(id));
        });
}

function inserAppp(idUser, cb) {
    client.query('SELECT count(*) as count FROM public.client_applications;')
        .then(res => {
            const queryApp = 'INSERT INTO public.client_applications(id, name, url, support_url, callback_url, key, secret, user_id, created_at, updated_at,  ' +
                'allow_read_prefs, allow_write_prefs, allow_write_diary, allow_write_api, allow_read_gpx, allow_write_gpx, allow_write_notes)' +
                ' VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)';
            const id = parseInt(res.rows[0].count) + 1;
            const name = 'iDEditor application';
            const url = process.env.ID_APPLICATION_URL || 'http://localhost'
            const support_url = url;
            const callback_url = url + '/callback';
            const key = process.env.ID_APPLICATION_KEY || 'MjogbcYQcMARSNsDsLLXYojWLitL5Fu9pk5DYIKv34331222';
            const secret = process.env.ID_APPLICATION_SECRET || '6PhYOaO5wmbzkw7TyBqmHB2ApohUiqWh1SPXLAMz34e1222';
            const user_id = idUser;
            const created_at = moment(new Date(), 'YYYY-MM-DD HH:MM:SS');
            const updated_at = moment(new Date(), 'YYYY-MM-DD HH:MM:SS');
            const allow_read_prefs = true;
            const allow_write_prefs = true;
            const allow_write_diary = true;
            const allow_write_api = true;
            const allow_read_gpx = true;
            const allow_write_gpx = true;
            const allow_write_notes = true;
            let valuesApp = [id, name, url, support_url, callback_url, key, secret, user_id, created_at, updated_at, allow_read_prefs, allow_write_prefs, allow_write_diary, allow_write_api, allow_read_gpx, allow_write_gpx, allow_write_notes];
            client.query(queryApp, valuesApp)
                // .then(result => console.log(result))
                .catch(e => console.error(e.stack))
                .then(() => cb({
                    name,
                    key,
                    secret,
                    url,
                    support_url
                }));
        });
}