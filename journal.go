package patrickoyarzun

import (
	"errors"
	"fmt"
	"html/template"
	"io"
	"io/ioutil"
	"mime"
	"mime/multipart"
	gomail "net/mail"
	"strings"
	"time"

	"github.com/russross/blackfriday"

	"google.golang.org/appengine/datastore"

	"golang.org/x/net/context"

	"google.golang.org/appengine"
	"google.golang.org/appengine/log"
	"google.golang.org/appengine/mail"

	"net/http"
)

type Journal struct {
	Body    string `datastore:",noindex"`
	Created time.Time
}

func handleError(c context.Context, rw http.ResponseWriter, description string, err error) {
	log.Errorf(c, "%s: %s", description, err.Error())
	http.Error(rw, description, http.StatusInternalServerError)
}

type JournalHandler struct {
	tmpl *template.Template
}

func NewJournalHandler() JournalHandler {
	funcMap := template.FuncMap{
		"markdown": func(in string) template.HTML {
			return template.HTML(blackfriday.MarkdownCommon([]byte(in)))
		},
	}
	tmpl := template.Must(template.New("root").Funcs(funcMap).ParseGlob("assets/*"))
	return JournalHandler{
		tmpl: tmpl,
	}
}

func (j JournalHandler) View(rw http.ResponseWriter, req *http.Request) {
	c := appengine.NewContext(req)
	var entries []Journal
	_, err := datastore.NewQuery("Journal").Order("-Created").GetAll(c, &entries)
	if err != nil {
		handleError(c, rw, "Unable to fetch entries", err)
		return
	}
	err = j.tmpl.ExecuteTemplate(rw, "journals.html", entries)
	if err != nil {
		handleError(c, rw, "Unable to render template", err)
		return
	}
}

func extractBody(msg *gomail.Message) (string, error) {
	mediaType, params, err := mime.ParseMediaType(msg.Header.Get("Content-Type"))
	if err != nil {
		return "", err
	}
	if strings.HasPrefix(mediaType, "multipart/") {
		mr := multipart.NewReader(msg.Body, params["boundary"])
		for {
			p, err := mr.NextPart()
			if err == io.EOF {
				return "", errors.New("message did not contain a text/plain part")
			}
			if err != nil {
				return "", err
			}
			slurp, err := ioutil.ReadAll(p)
			if err != nil {
				return "", err
			}
			if strings.Contains(p.Header.Get("Content-Type"), "text/plain") {
				return string(slurp), nil
			}
		}
		return "", errors.New("message did not contain a text/plain part")
	}
	body, err := ioutil.ReadAll(msg.Body)
	if err != nil {
		return "", err
	}
	return string(body), nil
}

func (j JournalHandler) ReceiveEntry(rw http.ResponseWriter, req *http.Request) {
	c := appengine.NewContext(req)
	msg, err := gomail.ReadMessage(req.Body)
	if err != nil {
		handleError(c, rw, "Invalid mail", err)
		return
	}

	body, err := extractBody(msg)
	if err != nil {
		handleError(c, rw, "Unable to read message body", err)
		return
	}
	journalEntry := Journal{
		Body:    string(body),
		Created: time.Now(),
	}
	key := datastore.NewKey(c, "Journal", "", 0, nil)
	_, err = datastore.Put(c, key, &journalEntry)
	if err != nil {
		handleError(c, rw, "Failed to put journal", err)
		return
	}
	_ = sendEmailToAdmin(c, "Journal received!", "Thanks.")
}

func (j JournalHandler) Reminder(rw http.ResponseWriter, req *http.Request) {
	c := appengine.NewContext(req)
	err := sendEmailToAdmin(c,
		fmt.Sprintf("Journal Entry for %s", time.Now().Format("02.01.06")),
		"",
	)
	if err != nil {
		handleError(c, rw, "Unable to send reminder email", err)
		return
	}
}

func sendEmailToAdmin(c context.Context, subject, body string) error {
	msg := &mail.Message{
		Sender:  "newjournal@patrickoyarzun.appspotmail.com",
		Subject: subject,
		Body:    body,
		To:      []string{"patrickoyarzun@gmail.com"},
	}
	err := mail.Send(c, msg)
	if err != nil {
		return err
	}
	return nil
}
