<?php
//Include Google Configuration File
include('config.php');

// This function performs a POST request to the Rest Api server to add the 
// access token related to logged in user.
function addToken($email, $access_token) {
    $curl = curl_init();

    curl_setopt_array($curl, array(
    CURLOPT_URL => 'https://pc169.math.unipr.it:3000/addToken',
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
        "email": "'.$email.'",
        "token": "'.$access_token.'"
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
    return $http_code;
}

?>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Menu nascosto con Bootstrap 5</title>
  
  <!-- script per gestire il la visualizzazione delle pagine -->
  <script type="text/javascript" src="menu.js"></script>

  <!-- Carica i file CSS di Bootstrap 5 -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css">
</head>
<body>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container-fluid">
      <a class="navbar-brand" href="#">BIOCHAIN-AI</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav">
          <li class="nav-item">
            <a class="nav-link active" aria-current="page" href="#" data-page="pages/login">Login</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#" id="insertData" data-page="pages/newData">Insert new data</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#" id="insertUser" data-page="pages/newUser">Insert new user</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#" id="catalog" data-page="pages/catalog">Catalog</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#" id="users" data-page="pages/users">Users</a>
          </li>
        </ul>
      </div>
    </div>
  </nav>

  <div class="container-fluid">
    <div class="row">
      <!-- Colonna del contenuto della pagina -->
      <div class="col-md-12">
        <div class="p-5">
          <div id="content">
            <?php
            //This $_GET["code"] variable value received after user has login into their 
            //Google Account redirct to PHP script then this variable value has been received
            if(isset($_GET["code"]) or isset($_SESSION['access_token'])){
              
              if(isset($_GET['code'])){
                  //It will Attempt to exchange a code for an valid authentication token.
                  $token = $google_client->fetchAccessTokenWithAuthCode($_GET["code"]);
                  //This condition will check there is any error occur during geting 
                  //authentication token. If there is no any error occur then it will
                  //execute if block of code/
                      
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

                      // Set the access token into the Rest server.
                      $http_code = addToken($data['email'], $token['access_token']);
                      
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

                          if(!empty($data['email'])){
                              $_SESSION['user_email_address'] = $data['email'];
                          }

                          if(!empty($data['gender'])){
                              $_SESSION['user_gender'] = $data['gender'];
                          }
                          
                          if(!empty($data['picture'])){
                              $_SESSION['user_image'] = $data['picture'];
                          }

                          echo "<div id='content'>";
                          include('pages/newData.php');
                          echo "</div>";

                      }
                      else{
                          $_SESSION['registered'] = FALSE;

                          echo "<h3>Non sei un utente registrato, non puoi effettuare operazioni sul sistema.</h3>";
                          echo "<h3>Contatta l'amministratore per autorizzarti.</h3>";
                          echo "<a class='btn btn-primary' role='button' href='https://pc169.math.unipr.it:443/logout.php'>Login con Google</a>";
                          return;
                      }
                  }
              }
            } else if (!isset($_SESSION['access_token'])) {
              $google_login_btn = '<a class="btn btn-primary" role="button" href="'.$google_client->createAuthUrl().'">Login con Google</a>';
              echo $google_login_btn;
              return;
            }
            ?>
        </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Carica i file JavaScript di Bootstrap 5 -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Script per la gestione del menu-->
  <script>
    // Seleziona tutte le voci di menu
    var menuItems = document.querySelectorAll('.nav-link');

    //Gestore di eventi clic a tutte le voci di menu
    menuItems.forEach(function(item) {
      item.addEventListener('click', function(e) {
        e.preventDefault(); // Impedisce il comportamento predefinito del clic sul link
        var page = this.getAttribute('data-page'); // Ottiene il nome della pagina dalla voce di menu

        loadPage(page); // Carica il contenuto della pagina
      });
    });

    document.getElementById('catalog').addEventListener('click', eseguiChiamataPHP);

    function eseguiChiamataPHP() {
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
          var response = xhr.responseText;
          console.log(response);
          document.getElementById("content").textContent = response;
        }
      };
      xhr.open('GET', '/restRequests/viewCatalog.php', true);
      xhr.send();
    }

    // Funzione per caricare il contenuto della pagina
    function loadPage(page) {
      // Crea un nuovo oggetto XMLHttpRequest per caricare il contenuto della pagina
      var xhr = new XMLHttpRequest();
      xhr.open('GET', page + '.php', true); // Carica la pagina PHP corrispondente
      xhr.onload = function() {
        if (this.status == 200) {
          document.getElementById('content').innerHTML = this.responseText; // Aggiorna il contenuto della pagina
        }
      };
      xhr.send();
    }

    function insertData() {
      event.preventDefault();
      const reader = new FileReader();
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
    // var data = document.getElementById("data").value;
    var data_file = document.getElementById("data-file").files[0];
    
    var data_file_encoded;

    reader.addEventListener(
        "load",
        () => {
            // convert image file to base64 string
            data_file_encoded = reader.result;
            xhr.send(JSON.stringify({"name": name, "description": description, "data": data_file_encoded, "token": token}));
            // document.write(reader.result);
        },
        false
    );

    if (data_file) {
        reader.readAsDataURL(data_file);
    }

    // Invia la richiesta
    // xhr.send(JSON.stringify({"name": name, "description": description, "data": data_file_encoded, "token": token}));
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
      xhr.open("POST", "https://pc169.math.unipr.it:3000/view", true);

      // Imposta la funzione di callback per gestire la risposta
      xhr.onload = function() {
          if (xhr.status === 200) {
              // La richiesta è stata completata con successo
              var response = xhr.responseText;
              // Puoi manipolare la risposta qui come desideri
              console.log(response);
              document.getElementById("content").textContent = response;
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

    function viewPersonalData() {
      // Crea l'oggetto XMLHttpRequest
      var xhr = new XMLHttpRequest();

      var token='<?php echo $_SESSION["access_token"];?>';
      // Definisci il tipo di richiesta e l'URL di destinazione
      xhr.open("POST", "http://localhost:3000/getPrivateData", true);

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
    </script>
</body>
</html> 