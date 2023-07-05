<?php
 
  //Include Google Configuration File
  include('config.php');
  if(!isset($_SESSION['access_token'])) {
   //Create a URL to obtain user authorization
   $google_login_btn = '<a href="'.$google_client->createAuthUrl().'">Login con Google</a>';
  } else {
 
    header("Location: oauth2callback.php");
  }
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login </title>
</head>
<body>
  <div class="container">
    <div class="row justify-content-center mt-5">
      <div class="col-md-6">
        <h1 class="text-center mb-4">Welcome to BIOCHAIN-AI</h1>
        <div class="d-grid gap-2">
        <?php
          echo '<button class="btn btn-lg btn-primary" type="button">'.$google_login_btn.'</button>';
        ?>
          <!-- <button class="btn btn-lg btn-danger" type="button">Logout</button> -->
        </div>
      </div>
    </div>
  </div>
</body>
</html>