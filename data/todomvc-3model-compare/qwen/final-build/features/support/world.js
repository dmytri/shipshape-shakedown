'use strict';

const { setWorldConstructor } = require('@cucumber/cucumber');
const { Window } = require('happy-dom');
const fs = require('fs');
const path = require('path');

const TODOAPP_HTML = `
<section class="todoapp">
  <header class="header">
    <h1>todos</h1>
    <input class="new-todo" placeholder="What needs to be done?" autofocus>
  </header>
  <section class="main">
    <input id="toggle-all" class="toggle-all" type="checkbox">
    <label for="toggle-all">Mark all as complete</label>
    <ul class="todo-list"></ul>
  </section>
  <footer class="footer">
    <span class="todo-count"><strong>0</strong> items left</span>
    <ul class="filters">
      <li><a href="#/">All</a></li>
      <li><a href="#/active">Active</a></li>
      <li><a href="#/completed">Completed</a></li>
    </ul>
    <button class="clear-completed">Clear completed</button>
  </footer>
</section>
`;

class TodoWorld {
  constructor({ attach, parameters }) {
    this.attach = attach;
    this.parameters = parameters;
    this.window = null;
    this.document = null;
    this.savedTodos = null;
    this.savedHash = null;
  }

  setupPage() {
    const hash = this.savedHash || '';
    this.window = new Window({ url: 'http://localhost:8080/' + hash });
    this.document = this.window.document;
    this.document.body.innerHTML = TODOAPP_HTML;

    // Restore saved todos if doing a reload
    if (this.savedTodos !== null) {
      this.window.localStorage.setItem('todos-todomvc', this.savedTodos);
    }

    // Inject app CSS so computedStyle reflects it
    const appCss = fs.readFileSync(path.join(__dirname, '..', '..', 'css', 'app.css'), 'utf-8');
    const styleEl = this.document.createElement('style');
    styleEl.textContent = appCss;
    this.document.head.appendChild(styleEl);

    // Load and execute the app
    const appCode = fs.readFileSync(path.join(__dirname, '..', '..', 'js', 'app.js'), 'utf-8');
    this.window.eval(appCode);
  }

  reloadPage() {
    // Save localStorage and URL hash state before reload
    this.savedTodos = this.window.localStorage.getItem('todos-todomvc');
    this.savedHash = this.window.location.hash;
    // Reload (fresh window, preserve localStorage and hash)
    this.setupPage();
    // Clear saved state - it has been used
    this.savedTodos = null;
    this.savedHash = null;
  }

  getTodos() {
    return this.window._todoApp.getTodos();
  }

  addTodoToData(title, completed) {
    const todos = this.getTodos();
    todos.push({ id: Date.now() + Math.random(), title, completed });
    this.window._todoApp.setTodos(todos);
    this.window._todoApp.saveTodos();
    this.window._todoApp.render();
  }

  findTodoLiByTitle(title) {
    const items = this.document.querySelectorAll('.todo-list li');
    for (let i = 0; i < items.length; i++) {
      const label = items[i].querySelector('.view label');
      if (label && label.textContent === title) return items[i];
    }
    return null;
  }

  dispatchClick(element) {
    element.dispatchEvent(new this.window.MouseEvent('click', { bubbles: true }));
  }

  dispatchDblClick(element) {
    element.dispatchEvent(new this.window.MouseEvent('dblclick', { bubbles: true }));
  }

  dispatchKeyDown(element, keyCode) {
    element.dispatchEvent(new this.window.KeyboardEvent('keydown', { keyCode, bubbles: true }));
  }

  dispatchBlur(element) {
    element.dispatchEvent(new this.window.FocusEvent('blur', { bubbles: true }));
  }

  cleanup() {
    if (this.window && this.window.close) {
      this.window.close();
    }
    this.window = null;
    this.document = null;
    this.savedTodos = null;
  }
}

setWorldConstructor(TodoWorld);
