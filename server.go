package main

import (
	"net/http"
	"os"
)

func init() {
	http.Handle("/", http.FileServer(http.Dir("site/public")))
	http.Handle("/apps/", http.StripPrefix("/apps", http.FileServer(http.Dir("apps"))))
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	http.ListenAndServe(":"+port, nil)
}
