package main

import (
	"crypto/rand"
	"encoding/base64"
	"encoding/gob"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/gorilla/sessions"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

var (
	googleOauthConfig *oauth2.Config
)

// Used for login
var (
	b                = make([]byte, 16)
	_, _             = rand.Read(b)
	oauthStateString = base64.URLEncoding.EncodeToString(b)
)

// User holds a users account information
type User struct {
	Username      string
	Authenticated bool
}

// // This map stores all the sessions
// var active_session = map[string]session{}

var store = sessions.NewCookieStore([]byte(os.Getenv("SESSION_KEY")))

// Initialize configuration
func init() {
	googleOauthConfig = &oauth2.Config{
		RedirectURL:  "http://localhost:8080/callback",
		ClientID:     os.Getenv("GOOGLE_OAUTH_CLIENT_ID"),
		ClientSecret: os.Getenv("GOOGLE_OAUTH_CLIENT_SECRET"),
		Scopes:       []string{"https://www.googleapis.com/auth/userinfo.email"},
		Endpoint:     google.Endpoint,
	}

	store.Options = &sessions.Options{
		Path:     "/",
		MaxAge:   60 * 15,
		HttpOnly: true,
	}

	gob.Register(User{})
}

func main() {
	// Handle function

	// http.HandleFunc("/templates", handleTemplates)
	http.HandleFunc("/login", handleGoogleLogin)
	http.HandleFunc("/logout", handleLogout)
	http.HandleFunc("/callback", handleGoogleCallback)
	http.HandleFunc("/", handleMain)
	// Start the server
	http.ListenAndServe(":8080", nil)
}

// Render pages inside the static folder
func handleMain(w http.ResponseWriter, r *http.Request) {

	// Check the cookie
	session, _ := store.Get(r, "session-token")
	user := getUser(session)

	if auth := user.Authenticated; !auth {
		http.ServeFile(w, r, "./static/noAuth.html")
		return
	}

	// Session is ok, return the welcome page
	http.ServeFile(w, r, "./index.html")
}

// // Handle templates
// func handleTemplates(w http.ResponseWriter, r *http.Request) {
// 	var tmpl *template.Template
// 	p := "." + "/templates/" + r.URL.Path
// 	if p == "./templates/index.html" {
// 		p = "./templates/index.html"
// 		tmpl = template.Must(template.ParseFiles("./templates/index.html"))
// 	} else if p == "./templates/prova.html" {
// 		tmpl = template.Must(template.ParseFiles("./templates/prova.html"))
// 	}
// 	tmpl.Execute(w, r.URL.Path)
// }

// Handle Google login form
func handleGoogleLogin(w http.ResponseWriter, r *http.Request) {
	url := googleOauthConfig.AuthCodeURL(oauthStateString)
	http.Redirect(w, r, url, http.StatusTemporaryRedirect)
}

func handleLogout(w http.ResponseWriter, r *http.Request) {
	session, err := store.Get(r, "session-token")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	session.Values["user"] = User{}
	session.Options.MaxAge = -1

	err = session.Save(r, w)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	// Redirect to the home page
	http.Redirect(w, r, "http://localhost:8080/", http.StatusFound)
}

// Handles Google callback
func handleGoogleCallback(w http.ResponseWriter, r *http.Request) {
	content, err := getUserInfo(r.FormValue("state"), r.FormValue("code"))
	if err != nil {
		fmt.Println(err.Error())
		http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
		return
	}
	fmt.Print("aaa")

	var jsonContent map[string]interface{}
	json.Unmarshal(content, &jsonContent)
	fmt.Print("unmarshal")

	// fmt.Fprintf(w, "Raw content: %s", content)
	//fmt.Fprintf(w, "User ID: %s", jsonContent["id"])
	//fmt.Fprintf(w, "User email: %s", jsonContent["email"])

	// Cast to string
	email := fmt.Sprintf("%s", jsonContent["email"])

	session, err := store.Get(r, "session-token")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	user := &User{
		Username:      email,
		Authenticated: true,
	}

	session.Values["user"] = user
	err = session.Save(r, w)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	http.Redirect(w, r, "./index.html", http.StatusFound)
}

// Retrieve informations from Google response
func getUserInfo(state string, code string) ([]byte, error) {
	if state != oauthStateString {
		return nil, fmt.Errorf("invalid oauth state")
	}
	token, err := googleOauthConfig.Exchange(oauth2.NoContext, code)
	if err != nil {
		return nil, fmt.Errorf("code exchange failed: %s", err.Error())
	}
	response, err := http.Get("https://www.googleapis.com/oauth2/v2/userinfo?access_token=" + token.AccessToken)
	if err != nil {
		return nil, fmt.Errorf("failed getting user info: %s", err.Error())
	}
	defer response.Body.Close()
	contents, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return nil, fmt.Errorf("failed reading response body: %s", err.Error())
	}
	return contents, nil
}

// // This function returns True if the session time is older than now, False
// // otherwise
// func (s session) isExpired() bool {
// 	return s.expiry.Before(time.Now())
// }

// getUser returns a user from session s
// on error returns an empty user
func getUser(s *sessions.Session) User {
	val := s.Values["user"]
	var user = User{}
	user, ok := val.(User)
	if !ok {
		return User{Authenticated: false}
	}
	return user
}
