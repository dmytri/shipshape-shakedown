const { World } = require('@cucumber/cucumber');
const { Window } = require('happy-dom');
const fs = require('fs');
const path = require('path');

const TEMPLATE_PATH = path.resolve(__dirname, '../../assets/app-template.index.html');

class TodoWorld extends World {
  constructor(options) {
    super(options);
    this.window = null;
    this.document = null;
  }

  renderFresh() {
    const html = fs.readFileSync(TEMPLATE_PATH, 'utf-8');
    const window = new Window({ url: 'http://localhost/' });
    const document = window.document;

    document.write(html);
    document.close();

    // Reset localStorage
    window.localStorage.clear();

    this.window = window;
    this.document = document;

    return { window, document };
  }

  evaluateAppCode(code) {
    if (!this.window) throw new Error('Window not initialized');
    try {
      const fn = new this.window.Function('window', 'document', code);
      fn(this.window, this.document);
    } catch (e) {
      // App code may not exist yet, that's fine
    }
  }

  // Get the todo list items
  getTodoItems() {
    return Array.from(this.document.querySelectorAll('.todo-list li'));
  }

  getTodoItem(title) {
    return this.getTodoItems().find(li => {
      const label = li.querySelector('label');
      return label && label.textContent.trim() === title;
    });
  }

  getNewTodoInput() {
    return this.document.querySelector('.new-todo');
  }

  getToggleAll() {
    return this.document.querySelector('.toggle-all');
  }

  getClearCompleted() {
    return this.document.querySelector('.clear-completed');
  }

  getTodoCount() {
    return this.document.querySelector('.todo-count');
  }

  getMainSection() {
    return this.document.querySelector('.main');
  }

  getFooterSection() {
    return this.document.querySelector('.footer');
  }

  getFilterLink(name) {
    const filters = this.document.querySelectorAll('.filters a');
    return Array.from(filters).find(a => a.textContent.trim() === name);
  }
}

module.exports = { TodoWorld };