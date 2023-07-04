<?php
require_once 'vendor/autoload.php';

// Call Google API
$google_client = new Google_Client();
// $google_client->setAuthConfigFile('client_secrets.json');
$google_client->setClientId($_ENV['GOOGLE_OAUTH_CLIENT_ID_TEST_CHAINCODE']);
$google_client->setClientSecret($_ENV['GOOGLE_OAUTH_CLIENT_SECRET_TEST_CHAINCODE']);
$google_client->setRedirectUri('https://pc169.math.unipr.it:443/oauth2callback.php');
$google_client->addScope('email');
$google_client->addScope('profile');

// $google_oauthV2 = new Google_Service_Oauth2($google_client);
session_start();
?>
