<?php
include('config.php');
if(isset($_SESSION['access_token'])){
    echo "Autorizzato alla visualizzazione";
}
else{
    echo "Non sei autorizzato a visualizzare questa pagina";
}
echo "<br><a href='http://pc169.math.unipr.it:443/index.php'>Torna alla home</a>"
?>