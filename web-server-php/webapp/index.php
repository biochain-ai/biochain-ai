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
            <a class="nav-link" href="#" data-page="pages/newData">Insert new data</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#" data-page="pages/newUser">Insert new user</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#" data-page="pages/catalog">Catalog</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#" data-page="pages/users">Users</a>
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
          <div id="content"><?php include('pages/login.php'); ?></div>
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
    </script>
</body>
</html> 