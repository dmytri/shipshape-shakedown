/* @planks("the app has loaded with no stored todos") */
/* @planks("the app has loaded with todos:") */
/* @planks("the app has loaded") */
/* @planks("the user adds a todo titled {string}") */
/* @planks("the user attempts to add a todo with title {string}") */
/* @planks("the new-todo input is cleared") */
/* @planks("the todo list contains no items") */
/* @planks("the todo list contains an item with title {string}") */
/* @planks("the \"#main\" section is not visible") */
/* @planks("the \"#main\" section is visible") */
/* @planks("the user navigates to the {string} route") */
/* @planks("the app is at the default route {string}") */
/* @planks("the todo list shows items with titles {string} and {string}") */
/* @planks("the todo list shows only items with titles {string}") */
/* @planks("the filter link for {string} has the {string} class") */
/* @planks("the filter link for {string} does not have the {string} class") */
/* @planks("the app reloads") */
/* @planks("the route is {string}") */
/* @planks("the user captures the list element for the todo titled {string}") */
/* @planks("the captured element is still attached to the list") */
/* @planks("the captured element has the {string} class") */
/* @planks("the captured element does not have the {string} class") */
/* @planks("the checkbox for the todo titled {string} is not visible") */
/* @planks("the label for the todo titled {string} is not visible") */
/* @planks("the destroy button for the todo titled {string} is not visible") */
/* @planks("the user presses Enter in its edit field") */
/* @planks("the todos {string}, {string}, {string} exist") */
/* @planks("the user edits the second todo to {string}") */

(function () {
  'use strict';

  var ENTER_KEY = 13;
  var STORAGE_KEY = 'todos-vanilla';

  var todoApp = document.querySelector('.todoapp');
  var mainSection = document.querySelector('.main');
  var footer = document.querySelector('.footer');
  var newTodo = document.querySelector('.new-todo');
  var todoList = document.querySelector('.todo-list');
  var todoCount = document.querySelector('.todo-count');
  var clearCompleted = document.querySelector('.clear-completed');
  var toggleAll = document.querySelector('.toggle-all');

  var todos = [];
  var currentFilter = 'all';

  function loadTodos() {
    var stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        todos = JSON.parse(stored);
      } catch (e) {
        todos = [];
      }
    } else {
      todos = [];
    }
  }

  function saveTodos() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(todos));
  }

  function getFilter() {
    var hash = window.location.hash;
    if (hash === '#/active') { return 'active'; }
    if (hash === '#/completed') { return 'completed'; }
    return 'all';
  }

  function updateFilterUI() {
    var links = document.querySelectorAll('.filters a');
    for (var i = 0; i < links.length; i++) {
      links[i].classList.remove('selected');
    }
    var filter = currentFilter;
    var selector;
    if (filter === 'all') { selector = 'a[href="#/"]'; }
    else if (filter === 'active') { selector = 'a[href="#/active"]'; }
    else if (filter === 'completed') { selector = 'a[href="#/completed"]'; }
    var activeLink = document.querySelector('.filters ' + selector);
    if (activeLink) { activeLink.classList.add('selected'); }
  }

  function render() {
    // Reuse existing list elements to preserve element identity
    var existing = {};
    for (var i = 0; i < todoList.children.length; i++) {
      var li = todoList.children[i];
      var label = li.querySelector('label');
      if (label) {
        existing[label.textContent.trim()] = li;
      }
    }
    // Remove elements for todos that no longer exist
    var currentTitles = {};
    todos.forEach(function (t) { currentTitles[t.title] = true; });
    for (var key in existing) {
      if (!currentTitles[key]) {
        todoList.removeChild(existing[key]);
      }
    }
    // Add or update items, preserving existing elements
    todos.forEach(function (todo) {
      var li = existing[todo.title];
      if (li) {
        // Update existing element in place
        if (todo.completed) {
          li.className = 'completed';
        } else {
          li.className = '';
        }
        var show = currentFilter === 'all' ||
          (currentFilter === 'active' && !todo.completed) ||
          (currentFilter === 'completed' && todo.completed);
        li.style.display = show ? '' : 'none';
        var checkbox = li.querySelector('.toggle');
        if (checkbox) checkbox.checked = todo.completed;
        var label = li.querySelector('label');
        if (label) label.textContent = todo.title;
        var editInput = li.querySelector('.edit');
        if (editInput) editInput.value = todo.title;
      } else {
        li = document.createElement('li');
        if (todo.completed) {
          li.className = 'completed';
        }
        var show = currentFilter === 'all' ||
          (currentFilter === 'active' && !todo.completed) ||
          (currentFilter === 'completed' && todo.completed);
        if (!show) {
          li.style.display = 'none';
        }
        li.innerHTML =
          '<div class="view">' +
            '<input class="toggle" type="checkbox"' + (todo.completed ? ' checked' : '') + '>' +
            '<label>' + escapeHtml(todo.title) + '</label>' +
            '<button class="destroy"></button>' +
          '</div>' +
          '<input class="edit" value="' + escapeHtml(todo.title) + '">';
        todoList.appendChild(li);
      }
    });
    // Re-append children in model order so a title change does not move the row to the bottom
    var orderedChildren = [];
    todos.forEach(function (todo) {
      for (var ci = 0; ci < todoList.children.length; ci++) {
        var lbl = todoList.children[ci].querySelector('label');
        if (lbl && lbl.textContent.trim() === todo.title) {
          orderedChildren.push(todoList.children[ci]);
          break;
        }
      }
    });
    orderedChildren.forEach(function (li) {
      todoList.appendChild(li);
    });

    updateVisibility();
    updateCount();
    updateClearButton();
    updateToggleAll();
    updateFilterUI();
  }

  function escapeHtml(str) {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  function updateVisibility() {
    var hasTodos = todos.length > 0;
    mainSection.style.display = hasTodos ? 'block' : 'none';
    footer.style.display = hasTodos ? 'block' : 'none';
  }

  function updateCount() {
    var active = todos.filter(function (t) { return !t.completed; }).length;
    var word = active === 1 ? 'item' : 'items';
    todoCount.innerHTML = '<strong>' + active + '</strong> ' + word + ' left';
  }

  function updateClearButton() {
    var hasCompleted = todos.some(function (t) { return t.completed; });
    clearCompleted.style.display = hasCompleted ? 'block' : 'none';
  }

  function updateToggleAll() {
    var allCompleted = todos.length > 0 && todos.every(function (t) { return t.completed; });
    toggleAll.checked = allCompleted;
  }

  function addTodo(title) {
    var trimmed = title.trim();
    if (trimmed === '') { return false; }
    todos.push({
      id: Date.now() + Math.random(),
      title: trimmed,
      completed: false
    });
    saveTodos();
    render();
    return true;
  }

  function toggleTodo(title) {
    for (var i = 0; i < todos.length; i++) {
      if (todos[i].title === title) {
        todos[i].completed = !todos[i].completed;
        saveTodos();
        render();
        return;
      }
    }
  }

  function removeTodo(title) {
    todos = todos.filter(function (t) { return t.title !== title; });
    saveTodos();
    render();
  }

  function toggleAllTodos() {
    var allCompleted = todos.every(function (t) { return t.completed; });
    for (var i = 0; i < todos.length; i++) {
      todos[i].completed = !allCompleted;
    }
    saveTodos();
    render();
  }

  function clearCompletedTodos() {
    todos = todos.filter(function (t) { return !t.completed; });
    saveTodos();
    render();
  }

  function getTodoIndexByTitle(title) {
    for (var i = 0; i < todos.length; i++) {
      if (todos[i].title === title) {
        return i;
      }
    }
    return -1;
  }

  function editTodo(oldTitle, newTitle) {
    var trimmed = newTitle.trim();
    if (trimmed === '') {
      removeTodo(oldTitle);
      return;
    }
    for (var i = 0; i < todos.length; i++) {
      if (todos[i].title === oldTitle) {
        todos[i].title = trimmed;
        break;
      }
    }
    saveTodos();
    render();
  }

  function cancelEdit(li) {
    li.classList.remove('editing');
    var viewDiv = li.querySelector('.view');
    if (viewDiv) {
      var children = viewDiv.children;
      for (var ci = 0; ci < children.length; ci++) {
        children[ci].style.display = '';
      }
    }
  }

  function commitEdit(li, editInput) {
    var label = li.querySelector('label');
    if (!label) { return; }
    var oldTitle = label.textContent.trim();
    var newTitle = editInput.value;
    editTodo(oldTitle, newTitle);
  }

  // Event delegation on todo list
  todoList.addEventListener('click', function (e) {
    var target = e.target;
    var li = target.closest('li');
    if (!li) { return; }

    if (target.classList.contains('toggle')) {
      var label = li.querySelector('label');
      if (label) {
        toggleTodo(label.textContent.trim());
      }
    }

    if (target.classList.contains('destroy')) {
      var label = li.querySelector('label');
      if (label) {
        removeTodo(label.textContent.trim());
      }
    }
  });

  // Double-click on label to enter editing mode
  todoList.addEventListener('dblclick', function (e) {
    var target = e.target;
    if (target.tagName !== 'LABEL') { return; }
    var li = target.closest('li');
    if (!li) { return; }
    li.classList.add('editing');
    // Hide the view children during editing (no CSS available in test environment)
    var viewDiv = li.querySelector('.view');
    if (viewDiv) {
      var children = viewDiv.children;
      for (var ci = 0; ci < children.length; ci++) {
        children[ci].style.display = 'none';
      }
    }
    var editInput = li.querySelector('.edit');
    if (editInput) {
      editInput.value = target.textContent.trim();

      // Attach handlers directly on the edit input
      editInput.onkeydown = function (ev) {
        if (ev.keyCode === ENTER_KEY) {
          editInput.blur();
        } else if (ev.keyCode === 27) {
          var label = li.querySelector('label');
          if (label) {
            editInput.value = label.textContent.trim();
          }
          cancelEdit(li);
        }
      };
      editInput.onblur = function () {
        commitEdit(li, editInput);
      };

      editInput.focus();
    }
  });

  // Mark-all checkbox
  toggleAll.addEventListener('change', function () {
    toggleAllTodos();
  });

  // Clear completed button
  clearCompleted.addEventListener('click', function () {
    clearCompletedTodos();
  });

  // Add id attributes matching feature CSS selectors
  var mainEl = document.querySelector('.main');
  if (mainEl) { mainEl.id = 'main'; }
  var footerEl = document.querySelector('.footer');
  if (footerEl) { footerEl.id = 'footer'; }

  window.addEventListener('hashchange', function () {
    currentFilter = getFilter();
    render();
  });

  function init() {
    currentFilter = getFilter();
    loadTodos();
    render();
  }

  newTodo.addEventListener('keypress', function (e) {
    if (e.keyCode === ENTER_KEY) {
      addTodo(newTodo.value);
      newTodo.value = '';
    }
  });

  init();
})();