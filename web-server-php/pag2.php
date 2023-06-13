<?php
include('config.php');
if(isset($_SESSION['access_token'])){
    echo "Autorizzato alla visualizzazione";
}
else{
    echo "Non sei autorizzato a visualizzare questa pagina";
}
echo "<a href='http://localhost:8080/index.php'>Torna alla home</a>"
?>