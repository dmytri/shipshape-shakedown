'use strict';

const { Given, When, Then, Before, After } = require('@cucumber/cucumber');
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const { Window } = require('happy-dom');

// --- Hooks ---

Before(function () {
  // World starts with no window
});

After(function () {
  this.cleanup();
});

// --- Helper: add todo with programmatic data and render ---

function addTodo(world, title, completed) {
  const todos = world.getTodos();
  const maxId = todos.reduce(function (m, t) { return Math.max(m, t.id); }, 0);
  todos.push({ id: maxId + 1, title: title, completed: completed });
  world.window._todoApp.setTodos(todos);
  world.window._todoApp.saveTodos();
  world.window._todoApp.render();
}

// --- Page render steps ---

Given('the index.html file exists at the project root', function () {
  const indexPath = path.join(__dirname, '..', '..', 'index.html');
  this.savedHtml = fs.readFileSync(indexPath, 'utf-8');
});

When('the page is examined', function () {
  const w = new Window();
  w.document.write(this.savedHtml);
  this.examinedDocument = w.document;
});

Then('the page contains the new-todo input with placeholder {string}', function (placeholder) {
  const input = this.examinedDocument.querySelector('.new-todo');
  assert(input, 'Expected .new-todo input');
  assert.strictEqual(input.getAttribute('placeholder'), placeholder);
});

Then('the page contains the todo-list section', function () {
  const el = this.examinedDocument.querySelector('.todo-list');
  assert(el, 'Expected .todo-list element');
});

Then('the page contains the footer with the item counter and filter links', function () {
  const footer = this.examinedDocument.querySelector('.footer');
  assert(footer, 'Expected .footer element');
  const counter = footer.querySelector('.todo-count');
  assert(counter, 'Expected .todo-count in footer');
  const filters = footer.querySelector('.filters');
  assert(filters, 'Expected .filters in footer');
  const links = filters.querySelectorAll('a');
  assert(links.length > 0, 'Expected filter links');
});

Then('the page includes a script tag loading js\\/app.js', function () {
  const script = this.examinedDocument.querySelector('script[src="js/app.js"]');
  assert(script, 'Expected script tag loading js/app.js');
});

// --- Given steps ---

Given('the page is loaded with no todos', function () {
  this.setupPage();
});

Given('the page is loaded with one active todo and no completed todos', function () {
  this.setupPage();
  addTodo(this, 'Task one', false);
});

Given('the page is loaded with two active todos', function () {
  this.setupPage();
  addTodo(this, 'Task one', false);
  addTodo(this, 'Task two', false);
});

Given('the page is loaded with two active todos and one completed todo', function () {
  this.setupPage();
  addTodo(this, 'Task one', false);
  addTodo(this, 'Task two', false);
  addTodo(this, 'Task completed', true);
});

Given('the page is loaded with a todo {string} that is not completed', function (title) {
  this.setupPage();
  addTodo(this, title, false);
});

Given('the page is loaded with a todo {string} that is completed', function (title) {
  this.setupPage();
  addTodo(this, title, true);
});

Given('the page is loaded with a completed todo {string}', function (title) {
  this.setupPage();
  addTodo(this, title, true);
});

Given('the page is loaded with the todos {string} and {string} both not completed', function (title1, title2) {
  this.setupPage();
  addTodo(this, title1, false);
  addTodo(this, title2, false);
});

Given('the page is loaded with the todos {string} and {string} both completed and the toggle all checkbox checked', function (title1, title2) {
  this.setupPage();
  addTodo(this, title1, true);
  addTodo(this, title2, true);
});

Given('the page is loaded with a completed todo {string} and an active todo {string}', function (completed, active) {
  this.setupPage();
  addTodo(this, completed, true);
  addTodo(this, active, false);
});

Given('the page is loaded with an active todo {string} and no completed todos', function (title) {
  this.setupPage();
  addTodo(this, title, false);
});

Given('the page is loaded with a todo {string} in edit mode', function (title) {
  this.setupPage();
  addTodo(this, title, false);
  // Enter edit mode by double-clicking the label
  const li = this.findTodoLiByTitle(title);
  const label = li.querySelector('.view label');
  this.dispatchDblClick(label);
  // Re-query since render() replaced the DOM nodes
  const updatedLi = this.findTodoLiByTitle(title);
  assert(updatedLi, `Todo "${title}" not found after entering edit mode`);
  assert(updatedLi.classList.contains('editing'), `should be in editing mode, classes: ${updatedLi.className}`);
});

// --- When steps ---

When('I type {string} in the new todo input and press Enter', function (text) {
  const input = this.document.querySelector('.new-todo');
  input.value = text;
  this.dispatchKeyDown(input, 13); // Enter
});

When('I press Enter in the new todo input without typing', function () {
  const input = this.document.querySelector('.new-todo');
  this.dispatchKeyDown(input, 13); // Enter
});

When('I click the checkbox for the todo {string}', function (title) {
  const li = this.findTodoLiByTitle(title);
  const checkbox = li.querySelector('.toggle');
  this.dispatchClick(checkbox);
});

When('I click the toggle all checkbox', function () {
  const checkbox = this.document.querySelector('.toggle-all');
  this.dispatchClick(checkbox);
  // Manually trigger change event since checkbox click might not fire 'change'
  checkbox.dispatchEvent(new this.window.Event('change', { bubbles: true }));
});

When('I click the checkbox for the todo {string} to make it not completed', function (title) {
  const li = this.findTodoLiByTitle(title);
  const checkbox = li.querySelector('.toggle');
  // The checkbox should be checked; clicking unchecks it
  this.dispatchClick(checkbox);
});

When('I click the destroy button for the todo {string}', function (title) {
  const li = this.findTodoLiByTitle(title);
  const destroyBtn = li.querySelector('.destroy');
  this.dispatchClick(destroyBtn);
});

When('I click the clear completed button', function () {
  const btn = this.document.querySelector('.clear-completed');
  this.dispatchClick(btn);
});

When('I double-click the label for the todo {string}', function (title) {
  const li = this.findTodoLiByTitle(title);
  const label = li.querySelector('.view label');
  this.dispatchDblClick(label);
});

When('I change the edit input value to {string} and press Enter', function (text) {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  editInput.value = text;
  this.dispatchKeyDown(editInput, 13); // Enter
});

When('I change the edit input value to {string} and move focus away', function (text) {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  editInput.value = text;
  this.dispatchBlur(editInput);
});

When('I change the edit input value to {string} and press Escape', function (text) {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  editInput.value = text;
  this.dispatchKeyDown(editInput, 27); // Escape
});

When('I complete one of the active todos', function () {
  // Click the first active todo's checkbox
  const items = this.document.querySelectorAll('.todo-list li:not(.completed)');
  if (items.length > 0) {
    const checkbox = items[0].querySelector('.toggle');
    this.dispatchClick(checkbox);
  }
});

When('I navigate to the active filter', function () {
  const link = this.document.querySelector('.filters a[href="#/active"]');
  this.dispatchClick(link);
});

When('I navigate to the completed filter', function () {
  const link = this.document.querySelector('.filters a[href="#/completed"]');
  this.dispatchClick(link);
});

When('I reload the page', function () {
  this.reloadPage();
});

// --- Then steps ---

Then('the todo list contains a todo titled {string}', function (title) {
  const li = this.findTodoLiByTitle(title);
  assert(li, `Expected todo list to contain "${title}" but it was not found`);
});

Then('the todo list does not contain a todo titled {string}', function (title) {
  const li = this.findTodoLiByTitle(title);
  assert(!li, `Expected todo list not to contain "${title}" but it was found`);
});

Then('the todo list is still empty', function () {
  const items = this.document.querySelectorAll('.todo-list li');
  assert.strictEqual(items.length, 0, `Expected empty todo list but found ${items.length} items`);
});

Then('the new todo input is empty', function () {
  const input = this.document.querySelector('.new-todo');
  assert.strictEqual(input.value, '', `Expected empty input but got "${input.value}"`);
});

Then('the counter displays {string}', function (text) {
  const counter = this.document.querySelector('.todo-count');
  assert.strictEqual(counter.textContent.trim(), text, `Expected counter "${text}" but got "${counter.textContent.trim()}"`);
});

Then('the todo {string} has the class {string}', function (title, className) {
  const li = this.findTodoLiByTitle(title);
  assert(li, `Todo "${title}" not found`);
  assert(li.classList.contains(className), `Expected todo "${title}" to have class "${className}" but classes are: ${li.className}`);
});

Then('the todo {string} does not have the class {string}', function (title, className) {
  const li = this.findTodoLiByTitle(title);
  assert(li, `Todo "${title}" not found`);
  assert(!li.classList.contains(className), `Expected todo "${title}" not to have class "${className}"`);
});

Then('the checkbox for the todo {string} is checked', function (title) {
  const li = this.findTodoLiByTitle(title);
  assert(li, `Todo "${title}" not found`);
  const checkbox = li.querySelector('.toggle');
  assert(checkbox.checked, `Expected checkbox for "${title}" to be checked`);
});

Then('the checkbox for the todo {string} is not checked', function (title) {
  const li = this.findTodoLiByTitle(title);
  assert(li, `Todo "${title}" not found`);
  const checkbox = li.querySelector('.toggle');
  assert(!checkbox.checked, `Expected checkbox for "${title}" not to be checked`);
});

Then('the toggle all checkbox is not checked', function () {
  const checkbox = this.document.querySelector('.toggle-all');
  assert(!checkbox.checked, 'Expected toggle-all checkbox not to be checked');
});

Then('the clear completed button is not visible', function () {
  const btn = this.document.querySelector('.clear-completed');
  assert(
    btn.style.display === 'none' || btn.offsetParent === null,
    'Expected clear-completed button to be hidden'
  );
});

Then('the main section is hidden', function () {
  const main = this.document.querySelector('.main');
  assert(
    main.style.display === 'none' || main.offsetParent === null,
    'Expected main section to be hidden'
  );
});

Then('the footer is hidden', function () {
  const footer = this.document.querySelector('.footer');
  assert(
    footer.style.display === 'none' || footer.offsetParent === null,
    'Expected footer to be hidden'
  );
});

Then('the edit input for the todo {string} is focused', function (title) {
  const li = this.findTodoLiByTitle(title);
  assert(li, `Todo "${title}" not found`);
  const editInput = li.querySelector('.edit');
  const ae = this.document.activeElement;
  assert(ae === editInput, `Expected edit input to be focused, activeElement was: ${ae ? ae.tagName + '.' + ae.className : 'null'}`);
});

Then('the todo list shows both {string} and {string}', function (title1, title2) {
  const li1 = this.findTodoLiByTitle(title1);
  const li2 = this.findTodoLiByTitle(title2);
  assert(li1, `Expected to see "${title1}" but not found`);
  assert(li2, `Expected to see "${title2}" but not found`);
});

Then('the todo list shows only {string}', function (title) {
  const items = this.document.querySelectorAll('.todo-list li');
  assert.strictEqual(items.length, 1, `Expected 1 todo but found ${items.length}`);
  const label = items[0].querySelector('.view label');
  assert.strictEqual(label.textContent, title, `Expected "${title}" but got "${label.textContent}"`);
});

Then('the {string} filter link has the class {string}', function (filterName, className) {
  const selectors = {
    'All': '.filters a[href="#/"]',
    'Active': '.filters a[href="#/active"]',
    'Completed': '.filters a[href="#/completed"]'
  };
  const link = this.document.querySelector(selectors[filterName]);
  assert(link, `Filter link "${filterName}" not found`);
  assert(link.classList.contains(className), `Expected "${filterName}" filter to have class "${className}"`);
});

Then('the todo has the key {string}, the key {string} with value {string}, and the key {string}', function (key1, key2, value, key3) {
  const todos = this.getTodos();
  assert(todos.length > 0, 'Expected at least one todo');
  const todo = todos[todos.length - 1]; // last added
  assert(key1 in todo, `Expected todo to have key "${key1}"`);
  assert.strictEqual(todo[key2], value, `Expected "${key2}" to be "${value}" but got "${todo[key2]}"`);
  assert(key3 in todo, `Expected todo to have key "${key3}"`);
});

// --- Durable DOM steps ---

When('I remember the li element for the todo {string}', function (title) {
  const li = this.findTodoLiByTitle(title);
  assert(li, `Todo "${title}" not found`);
  this._rememberedLis = { [title]: li };
});

When('I remember the li elements for todos {string} and {string}', function (title1, title2) {
  const li1 = this.findTodoLiByTitle(title1);
  const li2 = this.findTodoLiByTitle(title2);
  assert(li1, `Todo "${title1}" not found`);
  assert(li2, `Todo "${title2}" not found`);
  this._rememberedLis = { [title1]: li1, [title2]: li2 };
});

Then('the remembered li element is still in the DOM', function () {
  for (const [title, li] of Object.entries(this._rememberedLis)) {
    assert(this.document.contains(li), `Expected the original <li> for "${title}" to still be in the DOM after the action`);
    assert.strictEqual(li.parentElement.className, 'todo-list', `Expected the original <li> for "${title}" to still be a child of .todo-list`);
  }
});

Then('the remembered li elements are still in the DOM', function () {
  for (const [title, li] of Object.entries(this._rememberedLis)) {
    assert(this.document.contains(li), `Expected the original <li> for "${title}" to still be in the DOM after the action`);
    assert.strictEqual(li.parentElement.className, 'todo-list', `Expected the original <li> for "${title}" to still be a child of .todo-list`);
  }
});

Then('the view area for the todo {string} is hidden by CSS', function (title) {
  const li = this.findTodoLiByTitle(title);
  assert(li, `Todo "${title}" not found`);
  const viewEl = li.querySelector('.view');
  assert(viewEl, `Expected .view element inside li for "${title}"`);
  const computed = this.window.getComputedStyle(viewEl);
  assert.strictEqual(computed.display, 'none', `Expected .view to have display:none when editing, got "${computed.display}"`);
});
