<?php

use League\OAuth2\Client\Token\AccessToken;

/**
 * OAuth2 provider with configurable endpoints. The jbelien/oauth2-openstreetmap
 * provider hardcodes openstreetmap.org URLs; this subclass reads them from
 * constants defined in config.php so Level0 can talk to any OSM-compatible
 * website (openhistoricalmap.org, a dev instance, etc).
 */
class ConfigurableOAuthProvider extends \JBelien\OAuth2\Client\Provider\OpenStreetMap
{
    public function getBaseAuthorizationUrl()
    {
        return OSM_OAUTH2_AUTH_URL;
    }

    public function getBaseAccessTokenUrl(array $params)
    {
        return OSM_OAUTH2_TOKEN_URL;
    }

    public function getResourceOwnerDetailsUrl(AccessToken $token)
    {
        return OSM_USER_DETAILS_URL;
    }
}
