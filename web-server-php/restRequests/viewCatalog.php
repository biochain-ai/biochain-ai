<?php
include('../config.php');

$curl = curl_init();

curl_setopt_array($curl, array(
CURLOPT_URL => 'https://pc169.math.unipr.it:3000/view',
CURLOPT_RETURNTRANSFER => true,
CURLOPT_ENCODING => '',
CURLOPT_MAXREDIRS => 10,
CURLOPT_TIMEOUT => 0,
CURLOPT_HEADER => 1,
CURLOPT_SSL_VERIFYHOST => false,
CURLOPT_SSL_VERIFYPEER => false,
CURLOPT_FOLLOWLOCATION => true,
CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
CURLOPT_CUSTOMREQUEST => 'POST',
CURLOPT_POSTFIELDS =>'{
    "function": "catalogue",
    "token": "'.$_SESSION["access_token"].'"
}',
CURLOPT_HTTPHEADER => array(
    'Content-Type: application/json'
),
));

$response = curl_exec($curl);
$header_size = curl_getinfo($curl, CURLINFO_HEADER_SIZE);
$header = substr($response, 0, $header_size);
$http_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);

if(curl_errno($curl)){
    echo 'Curl error: ' . curl_error($curl);
    return;
}

curl_close($curl);
echo $response;

?>