const { Window } = require("happy-dom");
const fs = require("fs");
const path = require("path");

const htmlCache = fs.readFileSync(
  path.resolve(__dirname, "..", "..", "index.html"),
  "utf-8"
);
const appJsCache = fs.readFileSync(
  path.resolve(__dirname, "..", "..", "js", "app.js"),
  "utf-8"
);

let appCssCache = null;
try {
  appCssCache = fs.readFileSync(
    path.resolve(__dirname, "..", "..", "css", "app.css"),
    "utf-8"
  );
} catch (e) {
  // css/app.css may not exist yet
  appCssCache = null;
}

class TodoWorld {
  constructor() {
    this.window = null;
    this.document = null;
    this.localStorage = null;
    this.rememberedElement = null;
    this.rememberedElements = null;
  }

  async loadApp() {
    const window = new Window();
    this.window = window;
    this.document = window.document;
    this.localStorage = window.localStorage;

    this.document.write(htmlCache);

    // Inject app.css as inline style so happy-dom applies it
    if (appCssCache) {
      const styleEl = this.document.createElement("style");
      styleEl.textContent = appCssCache;
      this.document.head.appendChild(styleEl);
    }

    this.window.eval(appJsCache);

    const autofocusEl = this.document.querySelector("[autofocus]");
    if (autofocusEl && typeof autofocusEl.focus === "function") {
      autofocusEl.focus();
    }

    await new Promise((r) => setTimeout(r, 0));
  }

  reload() {
    // Properly simulate page reload: create new Window, copy localStorage and hash
    const oldStorage = {};
    const oldHash = this.window ? this.window.location.hash : "";
    if (this.localStorage) {
      const data = this.localStorage.getItem("todos-vanilla");
      if (data) oldStorage["todos-vanilla"] = data;
    }

    const window = new Window();
    this.window = window;
    this.document = window.document;
    this.localStorage = window.localStorage;

    // Restore localStorage
    for (const [key, value] of Object.entries(oldStorage)) {
      this.localStorage.setItem(key, value);
    }

    // Restore hash
    if (oldHash) {
      this.window.location.hash = oldHash;
    }

    this.document.write(htmlCache);

    // Inject app.css as inline style so happy-dom applies it
    if (appCssCache) {
      const styleEl = this.document.createElement("style");
      styleEl.textContent = appCssCache;
      this.document.head.appendChild(styleEl);
    }

    this.window.eval(appJsCache);

    const autofocusEl = this.document.querySelector("[autofocus]");
    if (autofocusEl && typeof autofocusEl.focus === "function") {
      autofocusEl.focus();
    }
  }

  findTodoItem(title) {
    const labels = this.document.querySelectorAll(".todo-list li label");
    for (const label of labels) {
      if (label.textContent === title) return label.closest("li");
    }
    return null;
  }
}

module.exports = { TodoWorld };