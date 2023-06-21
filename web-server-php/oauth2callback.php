<?php

//Include Google Configuration File
include('config.php');

echo '<html>
<head>
<title>Sezione privata</title>
<body>
<div class="container">
<div class="card">
<div class="card-header">
Login effettuato con successo!
</div>';

//This $_GET["code"] variable value received after user has login into their Google Account redirct to PHP script then this variable value has been received
if(isset($_GET["code"])){
   
    //It will Attempt to exchange a code for an valid authentication token.
    $token = $google_client->fetchAccessTokenWithAuthCode($_GET["code"]);
    //This condition will check there is any error occur during geting authentication token. If there is no any error occur then it will execute if block of code/
        
    if(!isset($token['error'])){
        //Set the access token used for requests
        $google_client->setAccessToken($token['access_token']);
        //Store "access_token" value in $_SESSION variable for future use.
        $_SESSION['access_token'] = $token['access_token'];
        //Create Object of Google Service OAuth 2 class
        $google_service = new Google_Service_Oauth2($google_client);
        //Get user profile data from google
        $data = $google_service->userinfo->get();
        //Below you can find Get profile data and store into $_SESSION variable

        // Send token to the Rest Api
        // $request = curl_init();

        // curl_setopt($request, CURLOPT_URL,"http://localhost:3000/addToken");
        // curl_setopt($request, CURLOPT_POST, 1);
        // curl_setopt($request, CURLOPT_POSTFIELDS, 
        //          http_build_query(array('email' => $data['email'], 'token' => $token['access_token'])));

        // // catch the response
        // curl_setopt($request, CURLOPT_RETURNTRANSFER, 1);
        // curl_setopt($request, CURLOPT_SSL_VERIFYPEER, 0);
        // curl_setopt($request, CURLOPT_SSL_VERIFYHOST, 0);

        // $response = curl_exec($request);

        // curl_close ($request);
        $curl = curl_init();

        curl_setopt_array($curl, array(
        CURLOPT_URL => 'http://rest-api-go:3000/addToken',
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
            "email": "'.$data['email'].'",
            "token": "'.$token['access_token'].'"
        }',
        CURLOPT_HTTPHEADER => array(
            'Content-Type: application/json'
        ),
        ));

        $response = curl_exec($curl);
        $header_size = curl_getinfo($curl, CURLINFO_HEADER_SIZE);
        $header = substr($response, 0, $header_size);
        $http_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        // echo $http_code;
        // echo $response;
        // echo $header;

        if(curl_errno($curl)){
            echo 'Curl error: ' . curl_error($curl);
            return;
        }

        curl_close($curl);

        // // GET REQUEST
        // $curlSES=curl_init(); 
        // curl_setopt($curlSES,CURLOPT_URL,"http://localhost:3000/addToken?email=".$data['email']."&token=".$token['access_token']);
        // curl_setopt($curlSES,CURLOPT_RETURNTRANSFER, true);
        // $result=curl_exec($curlSES);
        // curl_close($curlSES);
        // echo $result;

        if ($http_code == 200) {
            $_SESSION['registered'] = TRUE;
            if(!empty($data['given_name'])){
                $_SESSION['user_first_name'] = $data['given_name'];
            }
            if(!empty($data['family_name'])){
                $_SESSION['user_last_name'] = $data['family_name'];
            }
            echo '<div class="card-body">
            <h5 class="card-title">';
            echo $_SESSION["user_first_name"].' '.$_SESSION["user_last_name"];
            echo '</h5>';

            if(!empty($data['email'])){
                $_SESSION['user_email_address'] = $data['email'];
            }

            echo '<p class="card-text">Email:- ';
            echo $_SESSION["user_email_address"];
            echo "</p>";
            if(!empty($data['gender'])){
                $_SESSION['user_gender'] = $data['gender'];
            }
            if(!empty($data['picture'])){
                $_SESSION['user_image'] = $data['picture'];
            }

            echo "</div>";
            echo "<a href='http://localhost:8080/pag2.php'>Vai a pagina 2</a>";
        }
        else{
            $_SESSION['registered'] = FALSE;

            echo "<h3>Non sei un utente registrato, non puoi effettuare operazioni sul sistema.</h3>";
            echo "<h3>Contatta l'amministratore per autorizzarti.</h3>";
            echo "<a href='http://localhost:8080/logout.php'>Logout</a>";

        }
    }
}

if(!isset($_SESSION['access_token'])) {
    echo "Non hai l'autorizzazione!";
    echo "<br><a href='http://localhost:8080/index.php'>Torna alla pagina iniziale</a>";
} 
?>
</body>
</html>