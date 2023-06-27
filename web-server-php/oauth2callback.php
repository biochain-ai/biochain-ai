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
            echo "<a href='http://localhost:8080/logout.php'>Logout</a>";

            echo '
            <hr>
            <h4>Inserisci un nuovo dato</h4>
            <form name="insertDataForm" id="insertDataForm" onSubmit="JavaScript:insertData()">
                <label for="firstname">Nome Dato</label>
                <input type="text" name="name" id="name" /><br />
                <label for="lastname">Descrizione</label>
                <input type="text" name="description" id="description"/><br />
                <label for="lastname">Dato</label>
                <input type="text" name="data" id="data"/><br />
                <input name="" type="submit" value="Inserisci il dato" />
            </form>
            
            <hr>
            <h4>Inserisci un nuovo utente</h4>
            <form name="addUserForm" id="addUserForm" onSubmit="JavaScript:addUser()">
                <label for="mail">Mail</label>
                <input type="text" name="mail" id="mail" /><br />
                <label for="commonname">Nome</label>
                <input type="text" name="commonname" id="commonname" /><br />
                <label for="org">Organizzazione</label>
                <input type="text" name="org" id="org"/><br />
                <label for="level">Livello</label>
                <input type="text" name="level" id="level"/><br />
                <input name="" type="submit" value="Inserisci l\'utente" />
            </form>
            
            <hr>
            <h4>Richiedi dato</h4>
            <form name="requestDataForm" id="requestDataForm" onSubmit="JavaScript:requestData()">
                <label for="dato">Dato</label>
                <input type="text" name="dato" id="dato" /><br />
                <input name="" type="submit" value="Richiedi il dato" />
            </form>

            <hr>
        
            <br>
            <button onclick="viewCatalogue()">Vedi il catalogo</button>
            <br>
            <br>
            <button onclick="viewAllUsers()">Visualizza tutti gli utenti</button>
            <br>
            <br>
            <button onclick="viewAllOrgs()">Visualizza le organizzazioni</button>
            <br>
            <br>
            <button onclick="viewRequests()">Visualizza le richieste dell\'organizzazione</button>
            <br>
            <br>
            <button onclick="viewAllRequests()">Visualizza tuttte le richieste</button>
            <br>
            
            
            <div>
                <p>Risultato:</p>
                <p id="res" style="background-color:rgb(88, 158, 214);"></p>
            </div>
            ';
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

<script>
function insertData() {
    event.preventDefault();
    var xhr = new XMLHttpRequest();
    var token='<?php echo $_SESSION["access_token"];?>';

    // Definisci il tipo di richiesta e l'URL di destinazione
    xhr.open("POST", "http://localhost:3000/insertData", true);
    // xhr.setRequestHeader("Accept", "application/json");
    // xhr.setRequestHeader("Content-Type", "application/json");

    // Imposta la funzione di callback per gestire la risposta
    xhr.onload = function() {
        if (xhr.status === 200) {
            // La richiesta è stata completata con successo
            var response = xhr.responseText;
            // Puoi manipolare la risposta qui come desideri
            console.log(response);
            document.getElementById("res").textContent = response
        } else {
            // Si è verificato un errore durante la richiesta
            console.error("Errore nella richiesta. Codice: " + xhr.status);
        }
    };

    // Leggi i dati dal form
    var name = document.getElementById("name").value;
    var description = document.getElementById("description").value;
    var data = document.getElementById("data").value;

    // Invia la richiesta
    xhr.send(JSON.stringify({"name": name, "description": description, "data": data, "token": token}));
    var insertForm = document.getElementById("insertDataForm");
    insertForm.reset();
}
function requestData() {
    event.preventDefault();
    var xhr = new XMLHttpRequest();
    var token='<?php echo $_SESSION["access_token"];?>';

    // Definisci il tipo di richiesta e l'URL di destinazione
    xhr.open("POST", "http://localhost:3000/requestData", true);
    // xhr.setRequestHeader("Accept", "application/json");
    // xhr.setRequestHeader("Content-Type", "application/json");

    // Imposta la funzione di callback per gestire la risposta
    xhr.onload = function() {
        if (xhr.status === 200) {
            // La richiesta è stata completata con successo
            var response = xhr.responseText;
            // Puoi manipolare la risposta qui come desideri
            console.log(response);
            document.getElementById("res").textContent = response
        } else {
            // Si è verificato un errore durante la richiesta
            console.error("Errore nella richiesta. Codice: " + xhr.status);
        }
    };

    // Leggi i dati dal form
    var data = document.getElementById("dato").value;

    // Invia la richiesta
    xhr.send(JSON.stringify({"data": data, "token": token}));
    var insertForm = document.getElementById("requestDataForm");
    insertForm.reset();
}

function addUser() {
    event.preventDefault();
    
    var xhr = new XMLHttpRequest();

    var token='<?php echo $_SESSION["access_token"];?>';

    // Definisci il tipo di richiesta e l'URL di destinazione
    xhr.open("POST", "http://localhost:3000/addUser", true);
    // xhr.setRequestHeader("Accept", "application/json");
    // xhr.setRequestHeader("Content-Type", "application/json");

    // Imposta la funzione di callback per gestire la risposta
    xhr.onload = function() {
        if (xhr.status === 200) {
            // La richiesta è stata completata con successo
            var response = xhr.responseText;
            // Puoi manipolare la risposta qui come desideri
            console.log(response);
            document.getElementById("res").textContent = response
        } else {
            // Si è verificato un errore durante la richiesta
            console.error("Errore nella richiesta. Codice: " + xhr.status);
        }
    };

    // Leggi i dati dal form
    var mail = document.getElementById("mail").value;
    var commonname = document.getElementById("commonname").value;
    var org = document.getElementById("org").value;
    var level = document.getElementById("level").value;

    // Crea l'oggetto dei dati da inviare come JSON
    var obj = {
        token: token,
        mail: mail,
        org: org,
        commonname: commonname,
        level: level
    };

    // Invia la richiesta
    xhr.send(JSON.stringify(obj));
    var insertForm = document.getElementById("addUserForm");
    insertForm.reset();
}

function viewCatalogue() {
    // Crea l'oggetto XMLHttpRequest
    var xhr = new XMLHttpRequest();

    var token='<?php echo $_SESSION["access_token"];?>';
    // Definisci il tipo di richiesta e l'URL di destinazione
    xhr.open("POST", "http://localhost:3000/view", true);

    // Imposta la funzione di callback per gestire la risposta
    xhr.onload = function() {
        if (xhr.status === 200) {
            // La richiesta è stata completata con successo
            var response = xhr.responseText;
            // Puoi manipolare la risposta qui come desideri
            console.log(response);
            document.getElementById("res").textContent = response
        } else {
            // Si è verificato un errore durante la richiesta
            console.error("Errore nella richiesta. Codice: " + xhr.status);
        }
    };

    // Crea l'oggetto dei dati da inviare come JSON
    var obj = {
        token: token,
        function: "catalogue",
    };

    // Invia la richiesta
    xhr.send(JSON.stringify(obj));
}

function viewAllUsers(){
    // Crea l'oggetto XMLHttpRequest
    var xhr = new XMLHttpRequest();

    var token='<?php echo $_SESSION["access_token"];?>';

    // Definisci il tipo di richiesta e l'URL di destinazione
    xhr.open("POST", "http://localhost:3000/viewAllUsers", true);

    // Imposta la funzione di callback per gestire la risposta
    xhr.onload = function() {
        if (xhr.status === 200) {
        // La richiesta è stata completata con successo
        var response = xhr.responseText;
        // Puoi manipolare la risposta qui come desideri
        console.log(response);
        document.getElementById("res").textContent = response
        } else {
        // Si è verificato un errore durante la richiesta
        console.error("Errore nella richiesta. Codice: " + xhr.status);
        }
    };

    // Crea l'oggetto dei dati da inviare come JSON
    var obj = {
        token: token,
    };

    // Invia la richiesta
    xhr.send(JSON.stringify(obj));
}

function viewAllOrgs(){
    // Crea l'oggetto XMLHttpRequest
    var xhr = new XMLHttpRequest();

    var token='<?php echo $_SESSION["access_token"];?>';

    // Definisci il tipo di richiesta e l'URL di destinazione
    xhr.open("POST", "http://localhost:3000/viewAllOrgs", true);

    // Imposta la funzione di callback per gestire la risposta
    xhr.onload = function() {
        if (xhr.status === 200) {
        // La richiesta è stata completata con successo
        var response = xhr.responseText;
        // Puoi manipolare la risposta qui come desideri
        console.log(response);
        document.getElementById("res").textContent = response
        } else {
        // Si è verificato un errore durante la richiesta
        console.error("Errore nella richiesta. Codice: " + xhr.status);
        }
    };

    // Crea l'oggetto dei dati da inviare come JSON
    var obj = {
        token: token,
    };

    // Invia la richiesta
    xhr.send(JSON.stringify(obj));
}

function viewRequests(){
    // Crea l'oggetto XMLHttpRequest
    var xhr = new XMLHttpRequest();

    var token='<?php echo $_SESSION["access_token"];?>';
    // Definisci il tipo di richiesta e l'URL di destinazione
    xhr.open("POST", "http://localhost:3000/view", true);

    // Imposta la funzione di callback per gestire la risposta
    xhr.onload = function() {
        if (xhr.status === 200) {
            // La richiesta è stata completata con successo
            var response = xhr.responseText;
            // Puoi manipolare la risposta qui come desideri
            console.log(response);
            document.getElementById("res").textContent = response
        } else {
            // Si è verificato un errore durante la richiesta
            console.error("Errore nella richiesta. Codice: " + xhr.status);
        }
    };

    // Crea l'oggetto dei dati da inviare come JSON
    var obj = {
        token: token,
        function: "requests",
    };

    // Invia la richiesta
    xhr.send(JSON.stringify(obj));
}

function viewAllRequests(){
    // Crea l'oggetto XMLHttpRequest
    var xhr = new XMLHttpRequest();

    var token='<?php echo $_SESSION["access_token"];?>';
    // Definisci il tipo di richiesta e l'URL di destinazione
    xhr.open("POST", "http://localhost:3000/view", true);

    // Imposta la funzione di callback per gestire la risposta
    xhr.onload = function() {
        if (xhr.status === 200) {
            // La richiesta è stata completata con successo
            var response = xhr.responseText;
            // Puoi manipolare la risposta qui come desideri
            console.log(response);
            document.getElementById("res").textContent = response
        } else {
            // Si è verificato un errore durante la richiesta
            console.error("Errore nella richiesta. Codice: " + xhr.status);
        }
    };

    // Crea l'oggetto dei dati da inviare come JSON
    var obj = {
        token: token,
        function: "allrequests",
    };

    // Invia la richiesta
    xhr.send(JSON.stringify(obj));
}
	</script>
</body>
</html>