Absolutely! Let's build a full-stack CRUD (Create, Read, Update, Delete) application in Go with a simple and responsive UI. We'll utilize the following technologies:

* **Go**: Backend logic
* **HTMX**: Enables dynamic HTML updates without full page reloads
* **Tailwind CSS**: For styling the UI
* **SQLite**: Lightweight database for data persistence

This setup ensures a modern, efficient, and easy-to-maintain application.

---

## 🗂️ Project Structure

```
go-crud-app/
├── main.go
├── go.mod
├── templates/
│   ├── layout.html
│   ├── index.html
│   └── form.html
├── static/
│   └── styles.css
├── models/
│   └── item.go
└── database/
    └── db.go
```

---

## 🧱 Step-by-Step Implementation

### 1. Initialize the Go Module

```bash
mkdir go-crud-app
cd go-crud-app
go mod init go-crud-app
```

### 2. Define the Data Model

Create `models/item.go`:

```go
package models

type Item struct {
    ID    int
    Title string
}
```

### 3. Set Up the Database

Create `database/db.go`:

```go
package database

import (
    "database/sql"
    "log"

    _ "github.com/mattn/go-sqlite3"
)

var DB *sql.DB

func InitDB() {
    var err error
    DB, err = sql.Open("sqlite3", "./items.db")
    if err != nil {
        log.Fatal(err)
    }

    createTable := `
    CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
    );`
    _, err = DB.Exec(createTable)
    if err != nil {
        log.Fatal(err)
    }
}
```

Don't forget to install the SQLite driver:

```bash
go get github.com/mattn/go-sqlite3
```

### 4. Create HTML Templates

* `templates/layout.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Go CRUD App</title>
    <script src="https://unpkg.com/htmx.org@1.9.2"></script>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 p-6">
    <div class="container mx-auto">
        {{ template "content" . }}
    </div>
</body>
</html>
```

* `templates/index.html`:

```html
{{ define "content" }}
<h1 class="text-2xl font-bold mb-4">Items</h1>
<form hx-post="/create" hx-target="#items" hx-swap="beforeend" class="mb-4">
    <input type="text" name="title" placeholder="New item" class="border p-2 mr-2">
    <button type="submit" class="bg-blue-500 text-white px-4 py-2">Add</button>
</form>
<ul id="items">
    {{ range .Items }}
    <li id="item-{{ .ID }}" class="flex justify-between items-center bg-white p-2 mb-2 shadow">
        <span>{{ .Title }}</span>
        <button hx-delete="/delete/{{ .ID }}" hx-target="#item-{{ .ID }}" hx-swap="outerHTML" class="text-red-500">Delete</button>
    </li>
    {{ end }}
</ul>
{{ end }}
```

### 5. Implement the Main Application Logic

Create `main.go`:

```go
package main

import (
    "go-crud-app/database"
    "go-crud-app/models"
    "html/template"
    "log"
    "net/http"
    "strconv"
)

var templates = template.Must(template.ParseGlob("templates/*.html"))

func main() {
    database.InitDB()
    http.HandleFunc("/", indexHandler)
    http.HandleFunc("/create", createHandler)
    http.HandleFunc("/delete/", deleteHandler)
    log.Println("Server started at http://localhost:8080")
    http.ListenAndServe(":8080", nil)
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
    rows, err := database.DB.Query("SELECT id, title FROM items")
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    defer rows.Close()

    var items []models.Item
    for rows.Next() {
        var item models.Item
        if err := rows.Scan(&item.ID, &item.Title); err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)
            return
        }
        items = append(items, item)
    }

    data := struct {
        Items []models.Item
    }{
        Items: items,
    }

    templates.ExecuteTemplate(w, "layout.html", data)
}

func createHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        http.Redirect(w, r, "/", http.StatusSeeOther)
        return
    }
    title := r.FormValue("title")
    if title == "" {
        http.Redirect(w, r, "/", http.StatusSeeOther)
        return
    }
    result, err := database.DB.Exec("INSERT INTO items (title) VALUES (?)", title)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    id, err := result.LastInsertId()
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    item := models.Item{ID: int(id), Title: title}
    templates.ExecuteTemplate(w, "item.html", item)
}

func deleteHandler(w http.ResponseWriter, r *http.Request) {
    idStr := r.URL.Path[len("/delete/"):]
    id, err := strconv.Atoi(idStr)
    if err != nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    _, err = database.DB.Exec("DELETE FROM items WHERE id = ?", id)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    w.WriteHeader(http.StatusOK)
}
```

Create `templates/item.html`:

```html
<li id="item-{{ .ID }}" class="flex justify-between items-center bg-white p-2 mb-2 shadow">
    <span>{{ .Title }}</span>
    <button hx-delete="/delete/{{ .ID }}" hx-target="#item-{{ .ID }}" hx-swap="outerHTML" class="text-red-500">Delete</button>
</li>
```

### 6. Run the Application

```bash
go run main.go
```

Visit [http://localhost:8080](http://localhost:8080) to see your CRUD app in action!

---

## ✅ Features

* **Create**: Add new items using the input form.
* **Read**: View the list of items.
* **Delete**: Remove items without page reloads using HTMX.

---

## 🛠️ Next Steps

* **Update Functionality**: Implement editing of items.
* **Form Validation**: Add client-side and server-side validations.
* **Authentication**: Secure the application with user authentication.
* **Deployment**: Containerize the app using Docker and deploy to a cloud provider.

---

For a more advanced example integrating Go with HTMX and Tailwind CSS, you can explore this GitHub repository: [go-htmx-tailwind-example](https://github.com/jritsema/go-htmx-tailwind-example) .

Feel free to ask if you need further assistance or enhancements!
