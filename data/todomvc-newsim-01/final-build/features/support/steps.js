const { Given, When, Then } = require('@cucumber/cucumber');
const fs = require('fs');
const path = require('path');

// --- Helpers ---

function loadApp(world) {
  world.loadApp();
}

// --- Given ---

Given('the app has loaded with no stored todos', function () {
  this.localStorage.clear();
  this.window.location.hash = '';
  loadApp(this);
});

Given('the app has loaded with todos:', function (dataTable) {
  const todos = dataTable.hashes();
  const stored = todos.map(function (t) {
    return {
      id: Date.now() + Math.random(),
      title: t.title,
      completed: t.completed === 'true'
    };
  });
  this.localStorage.setItem('todos-vanilla', JSON.stringify(stored));
  this.window.location.hash = '';
  loadApp(this);
});

Given('the app has loaded', function () {
  this.localStorage.clear();
  this.window.location.hash = '';
  loadApp(this);
});

Given('localStorage contains a todo with title {string} that is not completed', function (title) {
  const stored = [{
    id: Date.now() + Math.random(),
    title: title,
    completed: false
  }];
  this.localStorage.setItem('todos-vanilla', JSON.stringify(stored));
});

// --- When ---

When('the user adds a todo titled {string}', function (title) {
  const input = this.document.querySelector('.new-todo');
  input.value = title;
  const event = new this.window.KeyboardEvent('keypress', { key: 'Enter', keyCode: 13 });
  input.dispatchEvent(event);
});

When('the user attempts to add a todo with title {string}', function (title) {
  const input = this.document.querySelector('.new-todo');
  input.value = title;
  const event = new this.window.KeyboardEvent('keypress', { key: 'Enter', keyCode: 13 });
  input.dispatchEvent(event);
});

When('the user clicks the toggle for the todo titled {string}', function (title) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      const toggle = items[i].querySelector('.toggle');
      toggle.click();
      return;
    }
  }
  throw new Error('Todo not found: ' + title);
});

When('the user clicks the mark-all checkbox', function () {
  const checkbox = this.document.querySelector('.toggle-all');
  checkbox.click();
});

When('the user toggles the first todo as completed', function () {
  const items = this.document.querySelectorAll('.todo-list li');
  if (items.length > 0) {
    const toggle = items[0].querySelector('.toggle');
    toggle.click();
  }
});

When('the user toggles the second todo as completed', function () {
  const items = this.document.querySelectorAll('.todo-list li');
  if (items.length > 1) {
    const toggle = items[1].querySelector('.toggle');
    toggle.click();
  }
});

When('the user clicks the clear-completed button', function () {
  const button = this.document.querySelector('.clear-completed');
  button.click();
});

When('the user destroys the todo titled {string}', function (title) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      const destroy = items[i].querySelector('.destroy');
      destroy.click();
      return;
    }
  }
  throw new Error('Todo not found: ' + title);
});

When('the user double-clicks the todo titled {string}', function (title) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      const event = new this.window.MouseEvent('dblclick', { bubbles: true });
      label.dispatchEvent(event);
      return;
    }
  }
  throw new Error('Todo not found: ' + title);
});

When('the user changes the title to {string} and presses Enter', function (newTitle) {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (editInput) {
    editInput.value = newTitle;
    const event = new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 });
    editInput.dispatchEvent(event);
  }
});

When('the user changes the title to {string} and blurs the input', function (newTitle) {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (editInput) {
    editInput.value = newTitle;
    const event = new this.window.FocusEvent('blur');
    editInput.dispatchEvent(event);
  }
});

When('the user clears the title and presses Enter', function () {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (editInput) {
    editInput.value = '';
    const event = new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 });
    editInput.dispatchEvent(event);
  }
});

When('the user clears the title and blurs the input', function () {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (editInput) {
    editInput.value = '';
    const event = new this.window.FocusEvent('blur');
    editInput.dispatchEvent(event);
  }
});

When('the user changes the title to {string} and presses Escape', function (newTitle) {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (editInput) {
    editInput.value = newTitle;
    const event = new this.window.KeyboardEvent('keydown', { key: 'Escape', keyCode: 27 });
    editInput.dispatchEvent(event);
  }
});

Given('a todo {string} that is in edit mode', function (title) {
  const stored = JSON.stringify([{ id: Date.now() + Math.random(), title: title, completed: false }]);
  this.localStorage.setItem('todos-vanilla', stored);
  this.window.location.hash = '';
  loadApp(this);
  // Double-click the label to enter edit mode
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      const event = new this.window.MouseEvent('dblclick', { bubbles: true });
      label.dispatchEvent(event);
      return;
    }
  }
  throw new Error('Todo not found: ' + title);
});

When('the user presses Enter in its edit field', function () {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (!editInput) { throw new Error('Edit input not found'); }
  const event = new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 });
  editInput.dispatchEvent(event);
});

When('the user replaces the text with {string} and presses Enter', function (text) {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (!editInput) { throw new Error('Edit input not found'); }
  editInput.value = text;
  const event = new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 });
  editInput.dispatchEvent(event);
});

When('the user clears the edit field and presses Enter', function () {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (!editInput) { throw new Error('Edit input not found'); }
  editInput.value = '';
  const event = new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 });
  editInput.dispatchEvent(event);
});

Then('that edit field is no longer the focused element', function () {
  const editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (editInput) {
    if (this.document.activeElement === editInput) {
      throw new Error('Edit field is still the focused element');
    }
  }
});

Then('the todo\'s title is {string}', function (expectedTitle) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === expectedTitle) {
      return;
    }
  }
  throw new Error('Todo with title "' + expectedTitle + '" not found');
});

Then('there is exactly one todo', function () {
  const items = this.document.querySelectorAll('.todo-list li');
  if (items.length !== 1) {
    throw new Error('Expected exactly 1 todo, found ' + items.length);
  }
});

Then('there are no todos', function () {
  const items = this.document.querySelectorAll('.todo-list li');
  if (items.length > 0) {
    throw new Error('Expected no todos, found ' + items.length);
  }
});

When('the user navigates to the {string} route', function (route) {
  this.window.location.hash = route;
  const hashChange = new this.window.HashChangeEvent('hashchange');
  this.window.dispatchEvent(hashChange);
});

When('the app is at the default route {string}', function (route) {
  this.window.location.hash = route;
});

When('the app loads', function () {
  this.window.location.hash = '';
  loadApp(this);
});

When('the app reloads', function () {
  const stored = this.localStorage.getItem('todos-vanilla');
  this.localStorage.clear();
  if (stored) {
    this.localStorage.setItem('todos-vanilla', stored);
  }
  const hash = this.window.location.hash;
  this.window.location.hash = '';
  this.window.location.hash = hash;
  loadApp(this);
});

// --- Then ---

Then('the {string} section is not visible', function (sectionId) {
  const section = this.document.querySelector(sectionId);
  if (!section) {
    return; // element not present in DOM - treated as hidden
  }
  const style = this.window.getComputedStyle(section);
  if (style.display !== 'none' && !section.hidden) {
    throw new Error('Expected section ' + sectionId + ' to be hidden');
  }
});

Then('the {string} section is visible', function (sectionId) {
  const section = this.document.querySelector(sectionId);
  if (!section) {
    throw new Error('Section ' + sectionId + ' not found in DOM');
  }
  const style = this.window.getComputedStyle(section);
  if (style.display === 'none' || section.hidden) {
    throw new Error('Expected section ' + sectionId + ' to be visible');
  }
});

Then('the todo list contains an item with title {string}', function (title) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      return;
    }
  }
  throw new Error('Todo list does not contain item: ' + title);
});

Then('the new-todo input is cleared', function () {
  const input = this.document.querySelector('.new-todo');
  if (input.value !== '') {
    throw new Error('Expected new-todo input to be cleared, got: ' + input.value);
  }
});

Then('the todo list contains no items', function () {
  const items = this.document.querySelectorAll('.todo-list li');
  if (items.length > 0) {
    throw new Error('Expected empty todo list, found ' + items.length + ' items');
  }
});

Then('the todo item {string} has the {string} class', function (title, className) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      if (!items[i].classList.contains(className)) {
        throw new Error('Expected item to have class ' + className);
      }
      return;
    }
  }
  throw new Error('Todo not found: ' + title);
});

Then('the todo item {string} does not have the {string} class', function (title, className) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      if (items[i].classList.contains(className)) {
        throw new Error('Expected item not to have class ' + className);
      }
      return;
    }
  }
  throw new Error('Todo not found: ' + title);
});

Then('every todo item has the {string} class', function (className) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    if (!items[i].classList.contains(className)) {
      throw new Error('Expected all items to have class ' + className);
    }
  }
});

Then('no todo item has the {string} class', function (className) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    if (items[i].classList.contains(className)) {
      throw new Error('Expected no items to have class ' + className);
    }
  }
});

Then('the mark-all checkbox is not checked', function () {
  const checkbox = this.document.querySelector('.toggle-all');
  if (checkbox.checked) {
    throw new Error('Expected mark-all checkbox to be unchecked');
  }
});

Then('the mark-all checkbox is checked', function () {
  const checkbox = this.document.querySelector('.toggle-all');
  if (!checkbox.checked) {
    throw new Error('Expected mark-all checkbox to be checked');
  }
});

Then('the todo-count displays {string}', function (expectedText) {
  const countEl = this.document.querySelector('.todo-count');
  if (!countEl) {
    throw new Error('Todo-count element not found');
  }
  const text = countEl.textContent.trim().replace(/\s+/g, ' ');
  if (text !== expectedText) {
    throw new Error('Expected todo-count "' + expectedText + '", got "' + text + '"');
  }
});

Then('the clear-completed button is not visible', function () {
  const button = this.document.querySelector('.clear-completed');
  const style = this.window.getComputedStyle(button);
  if (style.display !== 'none' && !button.hidden) {
    throw new Error('Expected clear-completed button to be hidden');
  }
});

Then('the clear-completed button is visible', function () {
  const button = this.document.querySelector('.clear-completed');
  const style = this.window.getComputedStyle(button);
  if (style.display === 'none' || button.hidden) {
    throw new Error('Expected clear-completed button to be visible');
  }
});

Then('the todo list contains only items with titles {string}', function (expectedTitle) {
  const items = this.document.querySelectorAll('.todo-list li');
  const titles = [];
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label) {
      titles.push(label.textContent.trim());
    }
  }
  if (titles.length !== 1 || titles[0] !== expectedTitle) {
    throw new Error('Expected list with only "' + expectedTitle + '", got: ' + titles.join(', '));
  }
});

Then('localStorage contains a record with a todo titled {string}', function (title) {
  const data = this.localStorage.getItem('todos-vanilla');
  if (!data) {
    throw new Error('No todos in localStorage');
  }
  const todos = JSON.parse(data);
  const found = todos.filter(function (t) { return t.title === title; });
  if (found.length === 0) {
    throw new Error('localStorage does not contain todo: ' + title);
  }
});

Then('localStorage stores the todo {string} as completed', function (title) {
  const data = this.localStorage.getItem('todos-vanilla');
  if (!data) {
    throw new Error('No todos in localStorage');
  }
  const todos = JSON.parse(data);
  const found = todos.filter(function (t) { return t.title === title && t.completed === true; });
  if (found.length === 0) {
    throw new Error('localStorage does not have completed todo: ' + title);
  }
});

Then('localStorage does not contain any indication of editing state', function () {
  const data = this.localStorage.getItem('todos-vanilla');
  if (!data) return;
  const todos = JSON.parse(data);
  for (let i = 0; i < todos.length; i++) {
    if (todos[i].hasOwnProperty('editing')) {
      throw new Error('localStorage contains editing state');
    }
  }
});

Then('localStorage contains no record of a todo titled {string}', function (title) {
  const data = this.localStorage.getItem('todos-vanilla');
  if (!data) return;
  const todos = JSON.parse(data);
  const found = todos.filter(function (t) { return t.title === title; });
  if (found.length > 0) {
    throw new Error('localStorage still contains todo: ' + title);
  }
});

Then('the todo list shows items with titles {string} and {string}', function (title1, title2) {
  const items = this.document.querySelectorAll('.todo-list li:not([style*="display: none"])');
  const visibleTitles = [];
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label) {
      visibleTitles.push(label.textContent.trim());
    }
  }
  const expected = [title1, title2];
  if (visibleTitles.length !== expected.length ||
      visibleTitles.indexOf(title1) === -1 ||
      visibleTitles.indexOf(title2) === -1) {
    throw new Error('Expected visible items ' + expected.join(', ') + ', got: ' + visibleTitles.join(', '));
  }
});

Then('the todo list shows only items with titles {string}', function (expectedTitle) {
  const items = this.document.querySelectorAll('.todo-list li:not([style*="display: none"])');
  const visibleTitles = [];
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label) {
      visibleTitles.push(label.textContent.trim());
    }
  }
  if (visibleTitles.length !== 1 || visibleTitles[0] !== expectedTitle) {
    throw new Error('Expected visible item "' + expectedTitle + '", got: ' + visibleTitles.join(', '));
  }
});

Then('the todo list is empty', function () {
  const items = this.document.querySelectorAll('.todo-list li:not([style*="display: none"])');
  if (items.length > 0) {
    throw new Error('Expected empty todo list, found ' + items.length + ' items');
  }
});

Then('the filter link for {string} has the {string} class', function (linkText, className) {
  const links = this.document.querySelectorAll('.filters a');
  for (let i = 0; i < links.length; i++) {
    if (links[i].textContent.trim() === linkText) {
      if (!links[i].classList.contains(className)) {
        throw new Error('Expected filter link "' + linkText + '" to have class ' + className);
      }
      return;
    }
  }
  throw new Error('Filter link not found: ' + linkText);
});

Then('the filter link for {string} does not have the {string} class', function (linkText, className) {
  const links = this.document.querySelectorAll('.filters a');
  for (let i = 0; i < links.length; i++) {
    if (links[i].textContent.trim() === linkText) {
      if (links[i].classList.contains(className)) {
        throw new Error('Expected filter link "' + linkText + '" not to have class ' + className);
      }
      return;
    }
  }
  throw new Error('Filter link not found: ' + linkText);
});

Then('the route is {string}', function (expectedRoute) {
  if (this.window.location.hash !== expectedRoute) {
    throw new Error('Expected route "' + expectedRoute + '", got "' + this.window.location.hash + '"');
  }
});

// --- Captured element steps (todo-item.feature: preserve list elements) ---

When('the user captures the list element for the todo titled {string}', function (title) {
  const items = this.document.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      this._capturedElement = items[i];
      return;
    }
  }
  throw new Error('Todo not found: ' + title);
});

Then('the captured element is still attached to the list', function () {
  if (!this._capturedElement) {
    throw new Error('No captured element');
  }
  // Check that the element is still in the DOM by verifying it has a parent
  if (!this._capturedElement.parentNode) {
    throw new Error('Captured element is no longer attached to the DOM');
  }
  // Also verify it is still inside the todo list
  const list = this.document.querySelector('.todo-list');
  if (!list.contains(this._capturedElement)) {
    throw new Error('Captured element is no longer inside the todo list');
  }
});

Then('the captured element has the {string} class', function (className) {
  if (!this._capturedElement) {
    throw new Error('No captured element');
  }
  if (!this._capturedElement.classList.contains(className)) {
    throw new Error('Expected captured element to have class ' + className);
  }
});

Then('the captured element does not have the {string} class', function (className) {
  if (!this._capturedElement) {
    throw new Error('No captured element');
  }
  if (this._capturedElement.classList.contains(className)) {
    throw new Error('Expected captured element not to have class ' + className);
  }
});

// --- Editing-mode visibility steps (todo-editing.feature) ---

function getLiByTitle(doc, title) {
  const items = doc.querySelectorAll('.todo-list li');
  for (let i = 0; i < items.length; i++) {
    const label = items[i].querySelector('label');
    if (label && label.textContent.trim() === title) {
      return items[i];
    }
  }
  return null;
}

Then('the checkbox for the todo titled {string} is not visible', function (title) {
  const li = getLiByTitle(this.document, title);
  if (!li) {
    throw new Error('Todo not found: ' + title);
  }
  const checkbox = li.querySelector('.toggle');
  if (!checkbox) {
    throw new Error('Checkbox not found for todo: ' + title);
  }
  const style = this.window.getComputedStyle(checkbox);
  if (style.display !== 'none') {
    throw new Error('Expected checkbox for "' + title + '" to be hidden');
  }
});

Then('the label for the todo titled {string} is not visible', function (title) {
  const li = getLiByTitle(this.document, title);
  if (!li) {
    throw new Error('Todo not found: ' + title);
  }
  const label = li.querySelector('label');
  if (!label) {
    throw new Error('Label not found for todo: ' + title);
  }
  const style = this.window.getComputedStyle(label);
  if (style.display !== 'none') {
    throw new Error('Expected label for "' + title + '" to be hidden');
  }
});

Then('the destroy button for the todo titled {string} is not visible', function (title) {
  const li = getLiByTitle(this.document, title);
  if (!li) {
    throw new Error('Todo not found: ' + title);
  }
  const destroy = li.querySelector('.destroy');
  if (!destroy) {
    throw new Error('Destroy button not found for todo: ' + title);
  }
  const style = this.window.getComputedStyle(destroy);
  if (style.display !== 'none') {
    throw new Error('Expected destroy button for "' + title + '" to be hidden');
  }
});

// --- order-preservation steps (todo-editing.feature: order) ---

Given('the todos {string}, {string}, {string} exist', function (title1, title2, title3) {
  const todos = [
    { id: Date.now() + Math.random(), title: title1, completed: false },
    { id: Date.now() + Math.random(), title: title2, completed: false },
    { id: Date.now() + Math.random(), title: title3, completed: false }
  ];
  this.localStorage.setItem('todos-vanilla', JSON.stringify(todos));
  this.window.location.hash = '';
  loadApp(this);
});

When('the user edits the second todo to {string}', function (newTitle) {
  const items = this.document.querySelectorAll('.todo-list li');
  if (items.length < 2) {
    throw new Error('Expected at least 2 todos, found ' + items.length);
  }
  const secondLi = items[1];
  const label = secondLi.querySelector('label');
  if (!label) { throw new Error('Second todo has no label'); }
  // Double-click label to enter editing mode
  const dblclick = new this.window.MouseEvent('dblclick', { bubbles: true });
  label.dispatchEvent(dblclick);
  // Change the value and commit
  var editInput = this.document.querySelector('.todo-list li.editing .edit');
  if (!editInput) { throw new Error('Edit input not found'); }
  editInput.value = newTitle;
  var enterEvent = new this.window.KeyboardEvent('keydown', { key: 'Enter', keyCode: 13 });
  editInput.dispatchEvent(enterEvent);
});

Then('the todos are, in order, {string}, {string}, {string}', function (title1, title2, title3) {
  var items = this.document.querySelectorAll('.todo-list li');
  var titles = [];
  for (var i = 0; i < items.length; i++) {
    var label = items[i].querySelector('label');
    if (label) {
      titles.push(label.textContent.trim());
    }
  }
  var expected = [title1, title2, title3];
  if (titles.length !== expected.length) {
    throw new Error('Expected ' + expected.length + ' todos, got ' + titles.length + ': ' + titles.join(', '));
  }
  for (var j = 0; j < expected.length; j++) {
    if (titles[j] !== expected[j]) {
      throw new Error('Expected todos in order \"' + expected.join('\", \"') + '\", got \"' + titles.join('\", \"') + '\"');
    }
  }
});

// --- app-page.feature step definitions ---

const { Window } = require('happy-dom');

Given('the project root directory', function () {
  this.projectRoot = path.resolve(__dirname, '../..');
});

Then('a file named {string} exists', function (filename) {
  const filePath = path.join(this.projectRoot, filename);
  if (!fs.existsSync(filePath)) {
    throw new Error('File not found: ' + filePath);
  }
  this.currentFilePath = filePath;
});

Given('the file {string} exists at the project root', function (filename) {
  this.projectRoot = path.resolve(__dirname, '../..');
  const filePath = path.join(this.projectRoot, filename);
  if (!fs.existsSync(filePath)) {
    throw new Error('File not found: ' + filePath);
  }
  this.currentFilePath = filePath;
});

Then('the file contains a script element whose src attribute is {string}', function (expectedSrc) {
  const html = fs.readFileSync(this.currentFilePath, 'utf-8');
  const scriptRegex = new RegExp('<script[^>]*src="' + expectedSrc.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '"[^>]*>');
  if (!scriptRegex.test(html)) {
    throw new Error('Script with src="' + expectedSrc + '" not found in ' + this.currentFilePath);
  }
});

Then('the file contains a {string} element with class {string}', function (tagName, className) {
  const html = fs.readFileSync(this.currentFilePath, 'utf-8');
  const win = new Window();
  const doc = win.document;
  doc.open();
  doc.write(html);
  doc.close();
  const elements = doc.querySelectorAll(tagName + '.' + className);
  if (elements.length === 0) {
    throw new Error('Element <' + tagName + ' class="' + className + '"> not found in ' + this.currentFilePath);
  }
  this.currentDoc = doc;
});

Then('the {string} element contains an input with class {string} and placeholder {string}', function (parentSelector, inputClass, placeholder) {
  const doc = this.currentDoc;
  const parent = doc.querySelector(parentSelector);
  if (!parent) {
    throw new Error('Parent element "' + parentSelector + '" not found');
  }
  const input = parent.querySelector('input.' + inputClass);
  if (!input) {
    throw new Error('Input with class "' + inputClass + '" not found inside "' + parentSelector + '"');
  }
  if (input.getAttribute('placeholder') !== placeholder) {
    throw new Error('Expected placeholder "' + placeholder + '", got "' + input.getAttribute('placeholder') + '"');
  }
});

Then('the file contains a section element with class {string}', function (className) {
  const html = fs.readFileSync(this.currentFilePath, 'utf-8');
  const win = new Window();
  const doc = win.document;
  doc.open();
  doc.write(html);
  doc.close();
  const elements = doc.querySelectorAll('section.' + className);
  if (elements.length === 0) {
    throw new Error('Section with class "' + className + '" not found');
  }
  this.currentDoc = doc;
});

Then('the {string} section contains a checkbox with class {string}', function (sectionSelector, checkboxClass) {
  const doc = this.currentDoc;
  const section = doc.querySelector('section.' + sectionSelector + ', .' + sectionSelector);
  if (!section) {
    throw new Error('Section "' + sectionSelector + '" not found');
  }
  const checkbox = section.querySelector('input[type="checkbox"].' + checkboxClass);
  if (!checkbox) {
    throw new Error('Checkbox with class "' + checkboxClass + '" not found in section "' + sectionSelector + '"');
  }
});

Then('the {string} section contains a list element with class {string}', function (sectionSelector, listClass) {
  const doc = this.currentDoc;
  const section = doc.querySelector('section.' + sectionSelector + ', .' + sectionSelector);
  if (!section) {
    throw new Error('Section "' + sectionSelector + '" not found');
  }
  const list = section.querySelector('ul.' + listClass);
  if (!list) {
    throw new Error('List with class "' + listClass + '" not found in section "' + sectionSelector + '"');
  }
});

Then('the file contains a footer element with class {string}', function (className) {
  const html = fs.readFileSync(this.currentFilePath, 'utf-8');
  const win = new Window();
  const doc = win.document;
  doc.open();
  doc.write(html);
  doc.close();
  const elements = doc.querySelectorAll('footer.' + className);
  if (elements.length === 0) {
    throw new Error('Footer with class "' + className + '" not found');
  }
  this.currentDoc = doc;
});

Then('the {string} section contains a span with class {string}', function (sectionSelector, spanClass) {
  const doc = this.currentDoc;
  const section = doc.querySelector('section.' + sectionSelector + ', .' + sectionSelector);
  if (!section) {
    throw new Error('Section "' + sectionSelector + '" not found');
  }
  const span = section.querySelector('span.' + spanClass);
  if (!span) {
    throw new Error('Span with class "' + spanClass + '" not found in section "' + sectionSelector + '"');
  }
});

Then('the {string} section contains filter links for {string}, {string}, and {string}', function (sectionSelector, link1, link2, link3) {
  const doc = this.currentDoc;
  const section = doc.querySelector('section.' + sectionSelector + ', .' + sectionSelector);
  if (!section) {
    throw new Error('Section "' + sectionSelector + '" not found');
  }
  const links = section.querySelectorAll('a');
  const linkTexts = [];
  for (var i = 0; i < links.length; i++) {
    linkTexts.push(links[i].textContent.trim());
  }
  var expected = [link1, link2, link3];
  for (var j = 0; j < expected.length; j++) {
    if (linkTexts.indexOf(expected[j]) === -1) {
      throw new Error('Filter link "' + expected[j] + '" not found in section "' + sectionSelector + '". Found: ' + linkTexts.join(', '));
    }
  }
});

Then('the {string} section contains a button with class {string}', function (sectionSelector, buttonClass) {
  const doc = this.currentDoc;
  const section = doc.querySelector('section.' + sectionSelector + ', .' + sectionSelector);
  if (!section) {
    throw new Error('Section "' + sectionSelector + '" not found');
  }
  const button = section.querySelector('button.' + buttonClass);
  if (!button) {
    throw new Error('Button with class "' + buttonClass + '" not found in section "' + sectionSelector + '"');
  }
});

When('the index.html is loaded in a browser', function () {
  const projectRoot = path.resolve(__dirname, '../..');
  const htmlPath = path.join(projectRoot, 'index.html');
  if (!fs.existsSync(htmlPath)) {
    throw new Error('index.html not found at project root');
  }
  const html = fs.readFileSync(htmlPath, 'utf-8');
  const win = new Window({ url: 'http://localhost/' });
  const doc = win.document;
  doc.open();
  doc.write(html);
  doc.close();
  win.localStorage.clear();

  // Load the app JavaScript
  const appJsPath = path.join(projectRoot, 'js/app.js');
  if (fs.existsSync(appJsPath)) {
    const appCode = fs.readFileSync(appJsPath, 'utf-8');
    try {
      win.eval(appCode);
    } catch (e) {
      // App code may fail on initial load with missing elements
    }
  }

  this.window = win;
  this.document = doc;
  this.localStorage = win.localStorage;
});

Then('the page displays the todo app header with the title {string}', function (expectedTitle) {
  const h1 = this.document.querySelector('h1');
  if (!h1) {
    throw new Error('No h1 element found');
  }
  if (h1.textContent.trim() !== expectedTitle) {
    throw new Error('Expected header title "' + expectedTitle + '", got "' + h1.textContent.trim() + '"');
  }
});

Then('the new-todo input is focused and ready for input', function () {
  const input = this.document.querySelector('.new-todo');
  if (!input) {
    throw new Error('New-todo input not found');
  }
  // Check that the input has autofocus attribute
  if (!input.hasAttribute('autofocus')) {
    throw new Error('New-todo input does not have autofocus attribute');
  }
});

// --- app-conformance.feature step definitions ---

Given('the app source at {string}', function (filePath) {
  const resolved = path.resolve(__dirname, '../..', filePath);
  this._appSource = fs.readFileSync(resolved, 'utf-8');
});

When('a conformance check inspects the edit-field Enter handler', function () {
  const src = this._appSource;
  // Find the dblclick handler body
  const dblclickMatch = src.match(/todoList\.addEventListener\(\'dblclick\'[\s\S]*?onkeydown\s*=\s*function\s*\([^)]*\)\s*\{([\s\S]*?)\}\s*;/);
  if (!dblclickMatch) {
    throw new Error('Could not locate editInput.onkeydown assignment in dblclick handler');
  }
  const onkeydownBody = dblclickMatch[1];
  // Extract the ENTER_KEY branch
  const enterBranchMatch = onkeydownBody.match(/if\s*\(ev\.keyCode\s*===?\s*ENTER_KEY\)\s*\{([\s\S]*?)\}/);
  if (!enterBranchMatch) {
    throw new Error('Could not locate ENTER_KEY branch in onkeydown handler');
  }
  this._enterBranch = enterBranchMatch[1].trim();
});

Then(/^the Enter handler calls editInput\.blur\(\)$/, function () {
  if (this._enterBranch.indexOf('editInput.blur()') === -1) {
    throw new Error('Enter handler does not call editInput.blur()');
  }
});

Then(/^the Enter handler does not call commitEdit directly$/, function () {
  if (this._enterBranch.indexOf('commitEdit') !== -1) {
    throw new Error('Enter handler calls commitEdit directly');
  }
});

Then('the main section and footer are hidden because there are no todos yet', function () {
  const main = this.document.querySelector('.main');
  const footer = this.document.querySelector('.footer');
  if (!main) {
    throw new Error('Main section not found');
  }
  if (!footer) {
    throw new Error('Footer not found');
  }
  // app.js sets display:none when there are no todos
  const mainStyle = this.window.getComputedStyle(main);
  if (mainStyle.display !== 'none') {
    throw new Error('Expected main section to be hidden');
  }
  const footerStyle = this.window.getComputedStyle(footer);
  if (footerStyle.display !== 'none') {
    throw new Error('Expected footer to be hidden');
  }
});
