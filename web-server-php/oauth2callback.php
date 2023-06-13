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
    }
}

if(!isset($_SESSION['access_token'])) {
    echo "Non hai l'autorizzazione!";
    echo "<br><a href='http://localhost:8080/index.php'>Torna alla pagina iniziale</a>";
} 
?>
<a href='http://localhost:8080/logout.php'>Logout</a>
<a href='http://localhost:8080/pag2.php'>Vai a pagina 2</a>
</body>
</html>