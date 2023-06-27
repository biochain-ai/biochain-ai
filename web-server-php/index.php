<?php
 
  //Include Google Configuration File
  include('config.php');
  if(!isset($_SESSION['access_token'])) {
   //Create a URL to obtain user authorization
   $google_login_btn = '<a href="'.$google_client->createAuthUrl().'">Login</a>';
  } else {
 
    header("Location: oauth2callback.php");
  }
?>
<html>
 <head>
  <title>Biochain Login</title>
   
 </head>
 <body>
  <div class="container">
    <h1 align="center">Benvenutə su Biochain-AI</h1>
   <br />
   <h2 align="center">Effettua il login con Google</h2>
   <br />
   <div class="panel panel-default">
   <?php
    echo '<div align="center">'.$google_login_btn . '</div>';
   ?>
   </div>
  </div>
 </body>
</html>