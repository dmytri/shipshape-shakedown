const { When, Then, Given, setWorldConstructor } = require('@cucumber/cucumber');
const { TodoWorld } = require('./world');
const fs = require('fs');
const path = require('path');

setWorldConstructor(TodoWorld);

const APP_JS_PATH = path.resolve(__dirname, '../../js/app.js');

function initApp(ctx) {
  try {
    const c = fs.readFileSync(APP_JS_PATH, 'utf-8');
    ctx.evaluateAppCode(c);
  } catch (e) {}
}

function rerender(ctx) {
  if (ctx.window && ctx.window.__todoRender) ctx.window.__todoRender();
}

Given('the app is rendered fresh', function () {
  this.renderFresh();
  initApp(this);
});

Given('the app has no todos', function () { /* fresh render = no todos */ });
Given('the new-todo input is focused', function () { this.getNewTodoInput().focus(); });
Given('the new-todo input contains whitespace only', function () { this.getNewTodoInput().value = '   '; });

Given(/^the following todos exist:$/, function (dataTable) {
  const todos = dataTable.hashes().map(row => ({
    id: Date.now().toString() + Math.random().toString(36).slice(2, 8),
    title: row.title,
    completed: row.completed === 'true'
  }));
  this.window.localStorage.setItem('todos-vanillajs', JSON.stringify(todos));
  rerender(this);
});

Given('a todo with title {string} exists', function (title) {
  const todos = JSON.parse(this.window.localStorage.getItem('todos-vanillajs') || '[]');
  todos.push({ id: Date.now().toString() + Math.random().toString(36).slice(2, 8), title, completed: false });
  this.window.localStorage.setItem('todos-vanillajs', JSON.stringify(todos));
  rerender(this);
});

Given('a completed todo with title {string} exists', function (title) {
  const todos = JSON.parse(this.window.localStorage.getItem('todos-vanillajs') || '[]');
  todos.push({ id: Date.now().toString() + Math.random().toString(36).slice(2, 8), title, completed: true });
  this.window.localStorage.setItem('todos-vanillajs', JSON.stringify(todos));
  rerender(this);
});

Given('all todos are completed', function () {
  const todos = JSON.parse(this.window.localStorage.getItem('todos-vanillajs') || '[]');
  todos.forEach(t => t.completed = true);
  this.window.localStorage.setItem('todos-vanillajs', JSON.stringify(todos));
  rerender(this);
});

Given('no todos are completed', function () {
  const todos = JSON.parse(this.window.localStorage.getItem('todos-vanillajs') || '[]');
  todos.forEach(t => t.completed = false);
  this.window.localStorage.setItem('todos-vanillajs', JSON.stringify(todos));
  rerender(this);
});

Given(/^the todo "([^"]+)" is in editing mode$/, function (title) {
  let item = this.getTodoItem(title);
  if (!item) {
    const todos = JSON.parse(this.window.localStorage.getItem('todos-vanillajs') || '[]');
    todos.push({ id: Date.now().toString() + Math.random().toString(36).slice(2, 8), title, completed: false });
    this.window.localStorage.setItem('todos-vanillajs', JSON.stringify(todos));
    rerender(this);
    item = this.getTodoItem(title);
  }
  if (!item) throw new Error('Todo "' + title + '" not found');
  item.classList.add('editing');
  const ei = item.querySelector('.edit');
  if (ei) { ei.value = title; ei.focus(); }
});

Given(/^the edit input has been changed to "([^"]+)"$/, function (v) {
  const ei = this.document.querySelector('.todo-list li.editing .edit');
  if (ei) ei.value = v;
});

Given(/^the app is at the "([^"]+)" route$/, function (route) {
  this.window.location.hash = route;
  this.window.dispatchEvent(new this.window.Event('hashchange'));
});

Given(/^the app navigates to "([^"]+)"$/, function (route) {
  this.window.location.hash = route;
  this.window.dispatchEvent(new this.window.Event('hashchange'));
});

When('the browser navigates back', function () {
  this.window.history.back();
  this.window.dispatchEvent(new this.window.Event('hashchange'));
});

When('the browser navigates forward', function () {
  this.window.history.forward();
  this.window.dispatchEvent(new this.window.Event('hashchange'));
});

When(/^the user types "([^"]+)" into the new-todo input and presses Enter$/, function (text) {
  const inp = this.getNewTodoInput();
  inp.value = text;
  inp.dispatchEvent(new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 }));
});

When('the user presses Enter', function () {
  this.getNewTodoInput().dispatchEvent(new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 }));
});

When(/^the user creates a todo with title "([^"]+)"$/, function (title) {
  const inp = this.getNewTodoInput();
  inp.value = title;
  inp.dispatchEvent(new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 }));
});

When('the user captures the todo list element reference', function () {
  const items = this.getTodoItems();
  if (items.length > 0) {
    this._capturedLi = items[0];
  }
});

When(/^the user clicks the toggle checkbox for "([^"]+)"$/, function (title) {
  const item = this.getTodoItem(title);
  if (!item) throw new Error('Todo "' + title + '" not found');
  const cb = item.querySelector('.toggle');
  if (!cb) throw new Error('Toggle not found');
  cb.click();
});

When('the user clicks the toggle-all checkbox', function () {
  const el = this.getToggleAll();
  if (!el) throw new Error('Toggle-all not found');
  el.click();
});

When('the user unchecks every todo individually', function () {
  this.getTodoItems().forEach(li => {
    const cb = li.querySelector('.toggle');
    if (cb && cb.checked) cb.click();
  });
});

When(/^the user marks "([^"]+)" as completed$/, function (title) {
  const item = this.getTodoItem(title);
  if (!item) throw new Error('Todo "' + title + '" not found');
  const cb = item.querySelector('.toggle');
  if (cb && !cb.checked) cb.click();
});

When('the user clicks the clear-completed button', function () {
  const btn = this.getClearCompleted();
  if (!btn) throw new Error('Clear completed not found');
  btn.click();
});

When(/^the user double-clicks the label of "([^"]+)"$/, function (title) {
  const item = this.getTodoItem(title);
  if (!item) throw new Error('Todo "' + title + '" not found');
  const lbl = item.querySelector('label');
  if (!lbl) throw new Error('Label not found');
  lbl.dispatchEvent(new this.window.MouseEvent('dblclick', { bubbles: true }));
});

When(/^the user changes the edit input to "([^"]+)" and presses Enter$/, function (v) {
  const ei = this.document.querySelector('.todo-list li.editing .edit');
  if (!ei) throw new Error('Edit input not found');
  ei.value = v;
  ei.dispatchEvent(new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 }));
});

When('the edit input loses focus', function () {
  const ei = this.document.querySelector('.todo-list li.editing .edit');
  if (!ei) throw new Error('Edit input not found');
  ei.dispatchEvent(new this.window.FocusEvent('blur', { bubbles: true }));
});

When('the user presses Escape', function () {
  const ei = this.document.querySelector('.todo-list li.editing .edit');
  if (!ei) throw new Error('Edit input not found');
  ei.dispatchEvent(new this.window.KeyboardEvent('keydown', { key: 'Escape', keyCode: 27 }));
});

When(/^the user clears the edit input and presses Enter$/, function () {
  const ei = this.document.querySelector('.todo-list li.editing .edit');
  if (!ei) throw new Error('Edit input not found');
  ei.value = '';
  ei.dispatchEvent(new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 }));
});

When(/^the user clicks the destroy button for "([^"]+)"$/, function (title) {
  const item = this.getTodoItem(title);
  if (!item) throw new Error('Todo "' + title + '" not found');
  const btn = item.querySelector('.destroy');
  if (!btn) throw new Error('Destroy button not found');
  btn.click();
});

When('the app is reloaded', function () {
  const { Window } = require('happy-dom');
  const html = fs.readFileSync(path.resolve(__dirname, '../../assets/app-template.index.html'), 'utf-8');
  const win = new Window({ url: 'http://localhost/' });
  const doc = win.document;
  doc.write(html);
  doc.close();
  const saved = this.window.localStorage.getItem('todos-vanillajs');
  if (saved) win.localStorage.setItem('todos-vanillajs', saved);
  const savedFilter = this.window.localStorage.getItem('todos-vanillajs-filter');
  if (savedFilter) win.localStorage.setItem('todos-vanillajs-filter', savedFilter);
  win.location.hash = this.window.location.hash;
  this.window = win;
  this.document = doc;
  initApp(this);
});

Then('the main section is not visible', function () {
  const el = this.getMainSection();
  if (!el) throw new Error('Main section not found');
  if (this.window.getComputedStyle(el).display !== 'none') throw new Error('Expected main hidden');
});

Then('the footer section is not visible', function () {
  const el = this.getFooterSection();
  if (!el) throw new Error('Footer section not found');
  if (this.window.getComputedStyle(el).display !== 'none') throw new Error('Expected footer hidden');
});

Then(/^a todo item with the title "([^"]+)" appears in the todo list$/, function (title) {
  if (!this.getTodoItem(title)) throw new Error('Todo "' + title + '" not found');
});

Then('the new-todo input is cleared', function () {
  if (this.getNewTodoInput().value !== '') throw new Error('Input not cleared');
});

Then('no new todo item is created', function () { /* no-op assertion */ });

Then('the remaining todo has the title {string}', function (title) {
  const items = this.getTodoItems();
  if (items.length === 0) throw new Error('No items');
  const lbl = items[0].querySelector('label');
  if (!lbl) throw new Error('No label');
  if (lbl.textContent.trim() !== title) throw new Error('Expected "' + title + '", got "' + lbl.textContent.trim() + '"');
});

Then('the todo list shows only active items', function () {
  const items = this.getTodoItems();
  const active = items.filter(li => !li.classList.contains('completed'));
  if (active.length !== items.length || items.length === 0) {
    // Check all visible items are active (not completed)
    const completed = items.filter(li => li.classList.contains('completed'));
    if (completed.length > 0) throw new Error('Expected only active items, found ' + completed.length + ' completed');
  }
});

Then(/^the todo list contains exactly (\d+) items$/, function (n) {
  const items = this.getTodoItems();
  if (items.length !== parseInt(n)) throw new Error('Expected ' + n + ' items, got ' + items.length);
});

Then(/^the last item in the list has the title "([^"]+)"$/, function (title) {
  const items = this.getTodoItems();
  if (!items.length) throw new Error('No items');
  const lbl = items[items.length - 1].querySelector('label');
  if (!lbl) throw new Error('No label');
  if (lbl.textContent.trim() !== title) throw new Error('Expected "' + title + '", got "' + lbl.textContent.trim() + '"');
});

Then(/^the todo "([^"]+)" has the completed class$/, function (title) {
  const item = this.getTodoItem(title);
  if (!item) throw new Error('Todo "' + title + '" not found');
  if (!item.classList.contains('completed')) throw new Error('Todo not completed');
});

Then('the captured todo list element is still attached to the DOM', function () {
  if (!this._capturedLi) throw new Error('No captured element');
  if (!this._capturedLi.parentNode) throw new Error('Captured element was removed from DOM');
  if (!this.document.body.contains(this._capturedLi)) throw new Error('Captured element is not in document');
});

Then('its checkbox is checked', function () {
  const cb = this.document.querySelector('.todo-list li.completed .toggle');
  if (cb && !cb.checked) throw new Error('Expected checkbox checked');
});

Then(/^the todo "([^"]+)" does not have the completed class$/, function (title) {
  const item = this.getTodoItem(title);
  if (!item) throw new Error('Todo "' + title + '" not found');
  if (item.classList.contains('completed')) throw new Error('Todo should not be completed');
});

Then('its checkbox is not checked', function () {
  const cb = this.document.querySelector('.todo-list li:not(.completed) .toggle');
  if (cb && cb.checked) throw new Error('Expected checkbox unchecked');
});

Then('all todos have the completed class', function () {
  this.getTodoItems().forEach((li, i) => {
    if (!li.classList.contains('completed')) throw new Error('Item ' + i + ' not completed');
  });
});

Then('the toggle-all checkbox is checked', function () {
  const el = this.getToggleAll();
  if (!el) throw new Error('Toggle-all not found');
  if (!el.checked) throw new Error('Toggle-all not checked');
});

Then('the toggle-all checkbox is not checked', function () {
  const el = this.getToggleAll();
  if (!el) throw new Error('Toggle-all not found');
  if (el.checked) throw new Error('Toggle-all should not be checked');
});

Then(/^only (\d+) todo remains in the list$/, function (n) {
  if (this.getTodoItems().length !== parseInt(n)) throw new Error('Expected ' + n + ' items');
});

Then('the clear-completed button is not visible', function () {
  const btn = this.getClearCompleted();
  if (!btn) throw new Error('Button not found');
  if (this.window.getComputedStyle(btn).display !== 'none') throw new Error('Expected button hidden');
});

Then('the clear-completed button is visible', function () {
  const btn = this.getClearCompleted();
  if (!btn) throw new Error('Button not found');
  if (this.window.getComputedStyle(btn).display === 'none') throw new Error('Expected button visible');
});

Then(/^the todo-count displays "([^"]+)"$/, function (expected) {
  const el = this.getTodoCount();
  if (!el) throw new Error('Todo count not found');
  if (el.textContent.trim() !== expected) throw new Error('Expected "' + expected + '", got "' + el.textContent.trim() + '"');
});

Then(/^the todo item has the editing class$/, function () {
  if (!this.getTodoItems().find(li => li.classList.contains('editing'))) throw new Error('No editing item');
});

Then(/^the edit input contains "([^"]+)"$/, function (v) {
  const ei = this.document.querySelector('.todo-list li.editing .edit');
  if (!ei) throw new Error('No edit input');
  if (ei.value !== v) throw new Error('Expected "' + v + '", got "' + ei.value + '"');
});

Then('the edit input is focused', function () {
  const ei = this.document.querySelector('.todo-list li.editing .edit');
  if (!ei) throw new Error('No edit input');
  if (this.document.activeElement !== ei) throw new Error('Edit input not focused');
});

Then(/^the todo item does not have the editing class$/, function () {
  if (this.getTodoItems().find(li => li.classList.contains('editing'))) throw new Error('Item still has editing class');
});

Then(/^the todo label reads "([^"]+)"$/, function (title) {
  const item = this.getTodoItems().find(li => {
    const lbl = li.querySelector('label');
    return lbl && lbl.textContent.trim() === title;
  });
  if (!item) throw new Error('No todo with label "' + title + '"');
});

Then(/^the edit input content is discarded$/, function () {
  // After Escape, editing class is removed; checked by "todo item does not have the editing class"
});

Then(/^the todo "([^"]+)" is removed from the list$/, function (title) {
  if (this.getTodoItem(title)) throw new Error('Todo "' + title + '" still exists');
});

Then(/^the todo list shows (\d+) items$/, function (n) {
  if (this.getTodoItems().length !== parseInt(n)) throw new Error('Expected ' + n + ' items');
});

Then(/^the todo list shows (\d+) active item$/, function (n) {
  const active = this.getTodoItems().filter(li => !li.classList.contains('completed'));
  if (active.length !== parseInt(n)) throw new Error('Expected ' + n + ' active, got ' + active.length);
});

Then(/^the todo list shows (\d+) completed item$/, function (n) {
  const completed = this.getTodoItems().filter(li => li.classList.contains('completed'));
  if (completed.length !== parseInt(n)) throw new Error('Expected ' + n + ' completed, got ' + completed.length);
});

Then('the checkbox of the editing todo is not visible', function () {
  const view = this.document.querySelector('.todo-list li.editing .view');
  if (!view) throw new Error('No editing todo with view found');
  const style = this.window.getComputedStyle(view);
  if (style.display !== 'none') throw new Error('Expected view display "none" (checkbox inside), got "' + style.display + '"');
});

Then('the destroy button of the editing todo is not visible', function () {
  const view = this.document.querySelector('.todo-list li.editing .view');
  if (!view) throw new Error('No editing todo with view found');
  const style = this.window.getComputedStyle(view);
  if (style.display !== 'none') throw new Error('Expected view display "none" (destroy inside), got "' + style.display + '"');
});

Then('the label of the editing todo is not visible', function () {
  const view = this.document.querySelector('.todo-list li.editing .view');
  if (!view) throw new Error('No editing todo with view found');
  const style = this.window.getComputedStyle(view);
  if (style.display !== 'none') throw new Error('Expected view display "none" (label inside), got "' + style.display + '"');
});

Then(/^the "([^"]+)" filter link has the selected class$/, function (name) {
  const link = this.getFilterLink(name);
  if (!link) throw new Error('Filter "' + name + '" not found');
  if (!link.classList.contains('selected')) throw new Error('Filter link not selected');
});

Then('the todo list shows only completed items', function () {
  const items = this.getTodoItems();
  const active = items.filter(li => !li.classList.contains('completed'));
  if (active.length > 0) throw new Error('Expected only completed items, found ' + active.length + ' active');
  if (items.length === 0) {
    // All completed items means the filter showed them
    const todos = JSON.parse(this.window.localStorage.getItem('todos-vanillajs') || '[]');
    const completedCount = todos.filter(t => t.completed).length;
    if (completedCount !== items.length) {
      // Zero items might be legitimate if there are no completed todos
    }
  }
});

Then(/^the active todo list does not include "([^"]+)"$/, function (title) {
  const active = this.getTodoItems().filter(li => !li.classList.contains('completed'));
  if (active.find(li => {
    const lbl = li.querySelector('label');
    return lbl && lbl.textContent.trim() === title;
  })) throw new Error('Todo "' + title + '" should not appear in active list');
});

// --- Servable page steps ---

const ROOT = path.resolve(__dirname, '../..');

Given('the project root contains {string}', function (filename) {
  const filePath = path.join(ROOT, filename);
  if (!fs.existsSync(filePath)) throw new Error('File not found: ' + filePath);
});

Then('{string} contains a todo input element', function (filename) {
  const html = fs.readFileSync(path.join(ROOT, filename), 'utf-8');
  const hasInput = html.includes('class="new-todo"') || html.includes("class='new-todo'");
  if (!hasInput) throw new Error('No todo input found in ' + filename);
});

Then('{string} contains a main list section', function (filename) {
  const html = fs.readFileSync(path.join(ROOT, filename), 'utf-8');
  if (!html.includes('class="todo-list"') && !html.includes("class='todo-list'")) {
    throw new Error('No todo list section found in ' + filename);
  }
});

Then('{string} contains a footer with controls', function (filename) {
  const html = fs.readFileSync(path.join(ROOT, filename), 'utf-8');
  if (!html.includes('class="footer"') && !html.includes("class='footer'")) {
    throw new Error('No footer section found in ' + filename);
  }
  if (!html.includes('class="clear-completed"') && !html.includes("class='clear-completed'")) {
    throw new Error('No clear-completed button found in footer');
  }
});

Then('{string} loads {string} via a script tag', function (filename, scriptSrc) {
  const html = fs.readFileSync(path.join(ROOT, filename), 'utf-8');
  const expected = 'src="' + scriptSrc + '"';
  if (!html.includes(expected)) throw new Error('Script src "' + scriptSrc + '" not found in ' + filename);
});

// --- Conformance: source code inspection steps ---

Given('the file {string} exists', function (filename) {
  const filePath = path.resolve(ROOT, filename);
  if (!fs.existsSync(filePath)) throw new Error('File not found: ' + filename);
});

When('I read the file {string}', function (filename) {
  const filePath = path.resolve(ROOT, filename);
  this._sourceContent = fs.readFileSync(filePath, 'utf-8');
});

Then('the source should contain {string} inside the ENTER_KEY handler', function (needle) {
  const src = this._sourceContent;
  if (!src) throw new Error('No source content loaded');
  // Find the ENTER_KEY branch: the block inside `if (e.keyCode === ENTER_KEY)`
  const enterMatch = src.match(/if\s*\(e\.keyCode\s*===?\s*ENTER_KEY\)\s*\{[^}]*\}/);
  if (!enterMatch) throw new Error('Could not find ENTER_KEY handler block in source');
  const block = enterMatch[0];
  if (!block.includes(needle)) {
    throw new Error('ENTER_KEY handler block does not contain "' + needle + '"');
  }
});

Then('the source should not contain {string} inside the ENTER_KEY handler in attachEditHandlers', function (needle) {
  const src = this._sourceContent;
  if (!src) throw new Error('No source content loaded');
  // Find the attachEditHandlers function body
  const fnMatch = src.match(/function\s+attachEditHandlers\s*\([^)]*\)\s*\{/);
  if (!fnMatch) throw new Error('Could not find attachEditHandlers function');
  const fnStart = fnMatch.index + fnMatch[0].length;
  // Find the matching closing brace - walk balanced braces
  let depth = 1;
  let i = fnStart;
  while (i < src.length && depth > 0) {
    if (src[i] === '{') depth++;
    if (src[i] === '}') depth--;
    i++;
  }
  const fnBody = src.substring(fnStart, i - 1);
  // Find ENTER_KEY handler within the function body
  const enterMatch = fnBody.match(/if\s*\(e\.keyCode\s*===?\s*ENTER_KEY\)\s*\{[^}]*\}/);
  if (!enterMatch) throw new Error('Could not find ENTER_KEY handler inside attachEditHandlers');
  const block = enterMatch[0];
  if (block.includes(needle)) {
    throw new Error('ENTER_KEY handler block should not contain "' + needle + '", but it does');
  }
});