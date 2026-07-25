/**
 * TodoMVC application - vanilla JS
 * @planks("I type {string} in the new todo input and press Enter")
 * @planks("I press Enter in the new todo input without typing")
 * @planks("I click the checkbox for the todo {string}")
 * @planks("I click the toggle all checkbox")
 * @planks("I click the destroy button for the todo {string}")
 * @planks("I click the clear completed button")
 * @planks("I double-click the label for the todo {string}")
 * @planks("I change the edit input value to {string} and press Enter")
 * @planks("I change the edit input value to {string} and move focus away")
 * @planks("I change the edit input value to {string} and press Escape")
 * @planks("I complete one of the active todos")
 * @planks("I navigate to the active filter")
 * @planks("I navigate to the completed filter")
 */
(function () {
  'use strict';

  var ENTER_KEY = 13;
  var ESC_KEY = 27;
  var STORAGE_KEY = 'todos-todomvc';

  var todos = [];
  var uid = 1;
  var currentFilter = 'all';
  var editingTodoId = null;

  function loadTodos() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        todos = JSON.parse(raw);
        uid = todos.reduce(function (max, t) { return Math.max(max, t.id); }, 0) + 1;
      }
    } catch (e) {
      todos = [];
    }
  }

  function saveTodos() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(todos));
  }

  function getVisibleTodos() {
    if (currentFilter === 'active') return todos.filter(function (t) { return !t.completed; });
    if (currentFilter === 'completed') return todos.filter(function (t) { return t.completed; });
    return todos;
  }

  function getActiveCount() {
    return todos.filter(function (t) { return !t.completed; }).length;
  }

  function getCompletedCount() {
    return todos.filter(function (t) { return t.completed; }).length;
  }

  function allCompleted() {
    return todos.length > 0 && todos.every(function (t) { return t.completed; });
  }

  function render() {
    var mainEl = document.querySelector('.main');
    var footerEl = document.querySelector('.footer');
    var todoList = document.querySelector('.todo-list');

    if (todos.length === 0) {
      mainEl.style.display = 'none';
      footerEl.style.display = 'none';
    } else {
      mainEl.style.display = '';
      footerEl.style.display = '';
    }

    var toggleAllCb = document.querySelector('.toggle-all');
    toggleAllCb.checked = allCompleted();

    // Render todo list — update existing DOM nodes in place, keyed by todo id
    var visible = getVisibleTodos();

    // Map of existing <li> elements by data-id
    var existingLis = {};
    var currentLiNodes = todoList.children;
    for (var i = currentLiNodes.length - 1; i >= 0; i--) {
      var id = currentLiNodes[i].getAttribute('data-id');
      if (id) existingLis[id] = currentLiNodes[i];
    }

    var seenIds = {};
    for (var v = 0; v < visible.length; v++) {
      var todo = visible[v];
      var idStr = String(todo.id);
      seenIds[idStr] = true;

      var li = existingLis[idStr];
      if (!li) {
        li = document.createElement('li');
        li.setAttribute('data-id', todo.id);
        li.innerHTML = '<div class="view">' +
          '<input class="toggle" type="checkbox">' +
          '<label></label>' +
          '<button class="destroy"></button>' +
          '</div>' +
          '<input class="edit">';
        li.querySelector('.edit').addEventListener('keydown', handleEditKeydown);
        li.querySelector('.edit').addEventListener('blur', handleEditBlur);
      }

      // Update classes
      var liClass = '';
      if (todo.completed) liClass += 'completed';
      if (todo.id === editingTodoId) liClass += (liClass ? ' ' : '') + 'editing';
      li.className = liClass;

      // Update toggle checkbox
      li.querySelector('.toggle').checked = todo.completed;

      // Update label text
      li.querySelector('.view label').textContent = todo.title;

      // Update edit input value
      li.querySelector('.edit').value = todo.title;

      // Append (moves existing node into correct order if already present)
      todoList.appendChild(li);
    }

    // Remove <li> elements that are no longer visible
    for (var eid in existingLis) {
      if (!seenIds[eid]) {
        todoList.removeChild(existingLis[eid]);
      }
    }

    // Update counter
    var activeCount = getActiveCount();
    var counterEl = document.querySelector('.todo-count');
    counterEl.innerHTML = '<strong>' + activeCount + '</strong> ' + (activeCount === 1 ? 'item' : 'items') + ' left';

    // Clear completed button visibility
    var clearBtn = document.querySelector('.clear-completed');
    if (getCompletedCount() === 0) {
      clearBtn.style.display = 'none';
    } else {
      clearBtn.style.display = '';
    }

    // Update filter selection
    var filterLinks = document.querySelectorAll('.filters a');
    for (var k = 0; k < filterLinks.length; k++) {
      filterLinks[k].classList.remove('selected');
    }
    if (currentFilter === 'all') {
      var allLink = document.querySelector('.filters a[href="#/"]');
      if (allLink) allLink.classList.add('selected');
    } else if (currentFilter === 'active') {
      var activeLink = document.querySelector('.filters a[href="#/active"]');
      if (activeLink) activeLink.classList.add('selected');
    } else if (currentFilter === 'completed') {
      var completedLink = document.querySelector('.filters a[href="#/completed"]');
      if (completedLink) completedLink.classList.add('selected');
    }
  }

  function escapeHtml(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  function findTodoByTitle(title) {
    for (var i = 0; i < todos.length; i++) {
      if (todos[i].title === title) return todos[i];
    }
    return null;
  }

  function findTodoLiByTitle(title) {
    var items = document.querySelectorAll('.todo-list li');
    for (var i = 0; i < items.length; i++) {
      var label = items[i].querySelector('.view label');
      if (label && label.textContent === title) return items[i];
    }
    return null;
  }

  function handleNewTodoKeydown(e) {
    if (e.keyCode !== ENTER_KEY) return;
    var value = e.target.value.trim();
    if (!value) return;
    todos.push({ id: uid++, title: value, completed: false });
    saveTodos();
    e.target.value = '';
    render();
  }

  function handleListClick(e) {
    var li = e.target.closest('li');
    if (!li) return;
    var id = parseInt(li.getAttribute('data-id'), 10);

    if (e.target.classList.contains('toggle')) {
      var todo = findTodoById(id);
      if (todo) {
        todo.completed = !todo.completed;
        saveTodos();
        render();
      }
    } else if (e.target.classList.contains('destroy')) {
      todos = todos.filter(function (t) { return t.id !== id; });
      saveTodos();
      render();
    }
  }

  function handleListDblClick(e) {
    var li = e.target.closest('li');
    if (!li) return;
    if (e.target.tagName.toLowerCase() === 'label') {
      var id = parseInt(li.getAttribute('data-id'), 10);
      editingTodoId = id;
      render();
      // Find the edit input in the newly rendered DOM
      var todoList = document.querySelector('.todo-list');
      var newLi = todoList.querySelector('li[data-id="' + id + '"]');
      if (newLi) {
        var editInput = newLi.querySelector('.edit');
        if (editInput) {
          editInput.focus();
        }
      }
    }
  }

  function handleEditKeydown(e) {
    var li = e.target.closest('li');
    if (!li) return;
    var id = parseInt(li.getAttribute('data-id'), 10);

    if (e.keyCode === ENTER_KEY) {
      commitEdit(id, e.target.value);
    } else if (e.keyCode === ESC_KEY) {
      editingTodoId = null;
      render();
    }
  }

  function handleEditBlur(e) {
    var li = e.target.closest('li');
    if (!li) return;
    var id = parseInt(li.getAttribute('data-id'), 10);
    if (editingTodoId === id) {
      commitEdit(id, e.target.value);
    }
  }

  function commitEdit(id, value) {
    var trimmed = value.trim();
    if (!trimmed) {
      todos = todos.filter(function (t) { return t.id !== id; });
    } else {
      var todo = findTodoById(id);
      if (todo) todo.title = trimmed;
    }
    editingTodoId = null;
    saveTodos();
    render();
  }

  function findTodoById(id) {
    for (var i = 0; i < todos.length; i++) {
      if (todos[i].id === id) return todos[i];
    }
    return null;
  }

  function handleToggleAll() {
    var checked = document.querySelector('.toggle-all').checked;
    for (var i = 0; i < todos.length; i++) {
      todos[i].completed = checked;
    }
    saveTodos();
    render();
  }

  function handleClearCompleted() {
    todos = todos.filter(function (t) { return !t.completed; });
    var toggleAllCb = document.querySelector('.toggle-all');
    toggleAllCb.checked = false;
    saveTodos();
    render();
  }

  function handleRoute() {
    var hash = window.location.hash;
    if (hash === '#/active') {
      currentFilter = 'active';
    } else if (hash === '#/completed') {
      currentFilter = 'completed';
    } else {
      currentFilter = 'all';
    }
    render();
  }

  function handleFilterClick(e) {
    var link = e.target.closest('.filters a');
    if (!link) return;
    e.preventDefault();
    window.location.hash = link.getAttribute('href');
    handleRoute();
  }

  function init() {
    loadTodos();

    var newTodoInput = document.querySelector('.new-todo');
    newTodoInput.addEventListener('keydown', handleNewTodoKeydown);

    var toggleAllCb = document.querySelector('.toggle-all');
    toggleAllCb.addEventListener('change', handleToggleAll);

    var clearBtn = document.querySelector('.clear-completed');
    clearBtn.addEventListener('click', handleClearCompleted);

    var todoList = document.querySelector('.todo-list');
    todoList.addEventListener('click', handleListClick);
    todoList.addEventListener('dblclick', handleListDblClick);

    var filters = document.querySelector('.filters');
    filters.addEventListener('click', handleFilterClick);

    window.addEventListener('hashchange', handleRoute);
    handleRoute();
    render();
  }

  // Expose for testing
  window._todoApp = {
    getTodos: function () { return todos; },
    setTodos: function (t) { todos = t; },
    setUid: function (n) { uid = n; },
    saveTodos: saveTodos,
    setFilter: function (f) { currentFilter = f; },
    getFilter: function () { return currentFilter; },
    setEditingId: function (id) { editingTodoId = id; },
    render: render,
    init: init
  };

  init();
})();
