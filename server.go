package main

import (
	"net/http"
	"os"
	"log"
	"github.com/gobuffalo/packr/v2"
	"github.com/NYTimes/gziphandler"
)

func newServer() http.Handler {
	mux := http.NewServeMux()
	mux.Handle("/", http.FileServer(packr.New("Static Assets", "site/public")))
	mux.Handle("/apps/", http.StripPrefix("/apps", http.FileServer(http.Dir("apps"))))
	return gziphandler.GzipHandler(mux)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Fatal(http.ListenAndServe(":"+port, newServer()))
}
