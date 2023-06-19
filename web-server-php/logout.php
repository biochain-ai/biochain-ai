<?php
include('config.php');

$curl = curl_init();

curl_setopt_array($curl, array(
CURLOPT_URL => 'http://rest-api-go:3000/removeToken',
CURLOPT_RETURNTRANSFER => true,
CURLOPT_ENCODING => '',
CURLOPT_MAXREDIRS => 10,
CURLOPT_TIMEOUT => 0,
CURLOPT_SSL_VERIFYHOST => false,
CURLOPT_SSL_VERIFYPEER => false,
CURLOPT_FOLLOWLOCATION => true,
CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
CURLOPT_CUSTOMREQUEST => 'POST',
CURLOPT_POSTFIELDS =>'{
    "token": "'.$_SESSION['access_token'].'"
}',
CURLOPT_HTTPHEADER => array(
    'Content-Type: application/json'
),
));

$response = curl_exec($curl);

echo $response;

if(curl_errno($curl)){
    echo 'Curl error: ' . curl_error($curl);
}

curl_close($curl);
//Reset OAuth access token
$google_client->revokeToken();
//Destroy entire session data.
session_destroy();
//redirect page to index.php

header('location:index.php');
?>