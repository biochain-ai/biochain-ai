package main

import (
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

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

// Initialize configuration
func init() {
	googleOauthConfig = &oauth2.Config{
		RedirectURL:  "http://localhost:8080/callback",
		ClientID:     os.Getenv("GOOGLE_OAUTH_CLIENT_ID"),
		ClientSecret: os.Getenv("GOOGLE_OAUTH_CLIENT_SECRET"),
		Scopes:       []string{"https://www.googleapis.com/auth/userinfo.email"},
		Endpoint:     google.Endpoint,
	}
}
func main() {
	// Handle function

	// http.HandleFunc("/templates", handleTemplates)
	http.HandleFunc("/login", handleGoogleLogin)
	http.HandleFunc("/callback", handleGoogleCallback)
	http.HandleFunc("/", handleMain)
	// Start the server
	http.ListenAndServe(":8080", nil)
}

// Render pages inside the static folder
func handleMain(w http.ResponseWriter, r *http.Request) {
	// fmt.Println(r.URL.Path)
	// p := "." + "/static/" + r.URL.Path
	// if p == "./static/" {
	// 	p = "./static/index.html"
	// }

	http.ServeFile(w, r, "./static/index.html")
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

// Handles Google callback
func handleGoogleCallback(w http.ResponseWriter, r *http.Request) {
	content, err := getUserInfo(r.FormValue("state"), r.FormValue("code"))
	if err != nil {
		fmt.Println(err.Error())
		http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
		return
	}

	var jsonContent map[string]interface{}
	json.Unmarshal(content, &jsonContent)
	// fmt.Fprintf(w, "Raw content: %s", content)
	//fmt.Fprintf(w, "User ID: %s", jsonContent["id"])
	//fmt.Fprintf(w, "User email: %s", jsonContent["email"])

	// Cast to string
	email := fmt.Sprintf("%s", jsonContent["email"])

	// Create a cookie
	cookie := http.Cookie{
		Name:   "BiochainCookie",
		Value:  email,
		MaxAge: 3600,
	}

	// Set the cookie
	http.SetCookie(w, &cookie)

	// Redirect to index page
	http.Redirect(w, r, "http://localhost:8080", http.StatusSeeOther)
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
