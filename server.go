package patrickoyarzun

import (
	"net/http"
)

func init() {
	journals := NewJournalHandler()
	http.HandleFunc("/journal/reminder", journals.Reminder)
	http.HandleFunc("/journal", journals.View)
	http.HandleFunc("/_ah/mail/", journals.ReceiveEntry)
	http.Handle("/", http.FileServer(http.Dir("site/public")))
	http.Handle("/apps/", http.StripPrefix("/apps", http.FileServer(http.Dir("apps"))))
}
