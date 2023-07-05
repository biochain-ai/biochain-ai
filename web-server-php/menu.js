// è stato modificato
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