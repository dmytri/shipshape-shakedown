(function (window, document) {
  'use strict';

  var ENTER_KEY = 13;
  var ESCAPE_KEY = 27;
  var STORAGE_KEY = 'todos-vanillajs';

  // Guard against double initialization
  if (window.__todoAppInitialized) return;
  window.__todoAppInitialized = true;

  var todoApp = document.querySelector('.todoapp');
  var main = document.querySelector('.main');
  var footer = document.querySelector('.footer');
  var newTodo = document.querySelector('.new-todo');
  var todoList = document.querySelector('.todo-list');
  var toggleAll = document.querySelector('.toggle-all');
  var todoCount = document.querySelector('.todo-count');
  var clearCompleted = document.querySelector('.clear-completed');
  var filters = document.querySelector('.filters');

  function loadTodos() {
    try {
      var data = window.localStorage.getItem(STORAGE_KEY);
      return data ? JSON.parse(data) : [];
    } catch (e) {
      return [];
    }
  }

  function saveTodos(todos) {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(todos));
  }

  function getId() {
    return Date.now().toString() + Math.random().toString(36).slice(2, 8);
  }

  function getFilteredTodos(todos, filter) {
    if (filter === 'active') return todos.filter(function (t) { return !t.completed; });
    if (filter === 'completed') return todos.filter(function (t) { return t.completed; });
    return todos;
  }

  function getActiveCount(todos) {
    return todos.filter(function (t) { return !t.completed; }).length;
  }

  function getCompletedCount(todos) {
    return todos.filter(function (t) { return t.completed; }).length;
  }

  function render() {
    var todos = loadTodos();
    var filter = window.__todoFilter || 'all';
    var filtered = getFilteredTodos(todos, filter);

    // Index existing <li> by data-id
    var itemMap = {};
    var existing = Array.prototype.slice.call(todoList.children);
    existing.forEach(function (li) {
      if (li.dataset && li.dataset.id) itemMap[li.dataset.id] = li;
    });

    // Reuse or create each row; fragment collects in display order
    var fragment = document.createDocumentFragment();
    filtered.forEach(function (todo) {
      var li = itemMap[todo.id];
      if (li) {
        // Update existing row in place
        li.className = todo.completed ? 'completed' : '';
        var view = li.querySelector('.view');
        if (view) view.style.display = '';
        var cb = li.querySelector('.toggle');
        if (cb) { cb.checked = todo.completed; }
        var label = li.querySelector('label');
        if (label) label.textContent = todo.title;
        var editInput = li.querySelector('.edit');
        if (editInput) editInput.value = todo.title;
        delete itemMap[todo.id];
      } else {
        // Create new row
        li = document.createElement('li');
        li.dataset.id = todo.id;
        li.className = todo.completed ? 'completed' : '';
        li.innerHTML = '<div class="view">' +
          '<input class="toggle" type="checkbox"' + (todo.completed ? ' checked' : '') + '>' +
          '<label>' + escapeHtml(todo.title) + '</label>' +
          '<button class="destroy"></button>' +
          '</div>' +
          '<input class="edit" value="' + escapeHtml(todo.title) + '">';
        attachEditHandlers(li);
      }
      fragment.appendChild(li);
    });

    // Remove stale rows (present in DOM but not in filtered set)
    for (var id in itemMap) {
      if (itemMap.hasOwnProperty(id)) {
        var stale = itemMap[id];
        if (stale.parentNode) stale.parentNode.removeChild(stale);
      }
    }

    // Replace list: existing nodes were moved to fragment, so only stale remain
    todoList.innerHTML = '';
    todoList.appendChild(fragment);

    var hasTodos = todos.length > 0;
    main.style.display = hasTodos ? '' : 'none';
    footer.style.display = hasTodos ? '' : 'none';

    var allCompleted = hasTodos && getActiveCount(todos) === 0;
    toggleAll.checked = allCompleted;

    var activeCount = getActiveCount(todos);
    var word = activeCount === 1 ? 'item' : 'items';
    todoCount.innerHTML = '<strong>' + activeCount + '</strong> ' + word + ' left';

    var completedCount = getCompletedCount(todos);
    clearCompleted.style.display = completedCount > 0 ? '' : 'none';

    var filterLinks = filters.querySelectorAll('a');
    Array.prototype.forEach.call(filterLinks, function (a) {
      var href = a.getAttribute('href');
      a.classList.toggle('selected',
        (href === '#/' && filter === 'all') ||
        (href === '#/active' && filter === 'active') ||
        (href === '#/completed' && filter === 'completed'));
    });
  }

  function escapeHtml(text) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(text));
    return div.innerHTML;
  }

  function addTodo(title) {
    var trimmed = title.trim();
    if (trimmed === '') return;
    var todos = loadTodos();
    todos.push({ id: getId(), title: trimmed, completed: false });
    saveTodos(todos);
    render();
  }

  function removeTodo(id) {
    var todos = loadTodos().filter(function (t) { return t.id !== id; });
    saveTodos(todos);
    render();
  }

  function toggleTodo(id) {
    var todos = loadTodos();
    todos.forEach(function (t) { if (t.id === id) t.completed = !t.completed; });
    saveTodos(todos);
    render();
  }

  function toggleAllTodos() {
    var todos = loadTodos();
    var allCompleted = todos.length > 0 && getActiveCount(todos) === 0;
    todos.forEach(function (t) { t.completed = !allCompleted; });
    saveTodos(todos);
    render();
  }

  function clearCompletedTodos() {
    var todos = loadTodos().filter(function (t) { return !t.completed; });
    saveTodos(todos);
    render();
  }

  function saveEdit(id, title) {
    var trimmed = title.trim();
    if (trimmed === '') {
      removeTodo(id);
      return;
    }
    var todos = loadTodos();
    todos.forEach(function (t) { if (t.id === t.id) { if (t.id === id) t.title = trimmed; } });
    saveTodos(todos);
    render();
  }

  function setFilter(filter) {
    window.__todoFilter = filter;
    try { window.localStorage.setItem(STORAGE_KEY + '-filter', filter); } catch (e) {}
    render();
  }

  // Event delegation for todo list — use data-id, never array index
  todoList.addEventListener('click', function (e) {
    var li = e.target.closest('li');
    if (!li) return;
    var id = li.dataset.id;
    if (!id) return;

    if (e.target.classList.contains('toggle')) {
      toggleTodo(id);
    } else if (e.target.classList.contains('destroy')) {
      removeTodo(id);
    }
  });

  todoList.addEventListener('dblclick', function (e) {
    var label = e.target.closest('label');
    if (!label) return;
    var li = label.closest('li');
    if (!li) return;
    li.classList.add('editing');
    var editInput = li.querySelector('.edit');
    editInput.focus();
    editInput.value = label.textContent;
    // Hide view during editing (also covered by CSS)
    var view = li.querySelector('.view');
    if (view) view.style.display = 'none';
  });

  function handleEditBlur(editInput, li) {
    if (!li || !li.classList.contains('editing')) return;
    var id = li.dataset.id;
    if (!id) return;
    saveEdit(id, editInput.value);
    // Restore view visibility
    var view = li.querySelector('.view');
    if (view) view.style.display = '';
  }

  // Direct keydown and blur handler on edit inputs (attached in render)
  function attachEditHandlers(li) {
    var editInput = li.querySelector('.edit');
    if (!editInput) return;
    editInput.addEventListener('keydown', function (e) {
      var id = li.dataset.id;
      if (!id) return;
      if (e.keyCode === ENTER_KEY) {
        e.preventDefault();
        editInput.blur();
      } else if (e.keyCode === ESCAPE_KEY) {
        e.preventDefault();
        li.classList.remove('editing');
        // Restore view visibility
        var view = li.querySelector('.view');
        if (view) view.style.display = '';
      }
    });
    editInput.addEventListener('blur', function () {
      handleEditBlur(editInput, li);
    });
  }

  newTodo.addEventListener('keydown', function (e) {
    if (e.keyCode === ENTER_KEY) {
      e.preventDefault();
      addTodo(newTodo.value);
      newTodo.value = '';
    }
  });

  toggleAll.addEventListener('click', function () {
    toggleAllTodos();
  });

  clearCompleted.addEventListener('click', function () {
    clearCompletedTodos();
  });

  filters.addEventListener('click', function (e) {
    var a = e.target.closest('a');
    if (!a) return;
    var href = a.getAttribute('href');
    if (href === '#/' || href === '#!/') setFilter('all');
    else if (href === '#/active') setFilter('active');
    else if (href === '#/completed') setFilter('completed');
  });

  window.addEventListener('hashchange', function () {
    var hash = window.location.hash;
    if (hash === '#/' || hash === '' || hash === '#!/') setFilter('all');
    else if (hash === '#/active') setFilter('active');
    else if (hash === '#/completed') setFilter('completed');
  });

  // Expose re-render for test support
  window.__todoRender = render;

  // Initialise filter from saved state
  try {
    var savedFilter = window.localStorage.getItem(STORAGE_KEY + '-filter');
    if (savedFilter) window.__todoFilter = savedFilter;
  } catch (e) {}

  render();

})(typeof window !== 'undefined' ? window : {}, typeof document !== 'undefined' ? document : {});