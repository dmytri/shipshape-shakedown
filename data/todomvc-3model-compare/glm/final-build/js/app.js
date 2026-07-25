/* @planks("the app has no todos") */
/* @planks("the app has a todo {string}") */
/* @planks("the app has todos {string} and {string}") */
/* @planks("the app has {int} active todos") */
/* @planks("the app has one active todo {string}") */
/* @planks("the app has completed todos {string} and {string}") */
/* @planks("the app has completed todo {string}") */
/* @planks("the app has only active todos") */
/* @planks("the app has active todos {string} and {string}") */
/* @planks("the app has no active todos") */
/* @planks("the app has completed todos {string} and {string} and the app has an active todo {string}") */
/* @planks("I enter {string} in the new todo input") */
/* @planks("I press Enter") */
/* @planks("I click the checkbox on the todo") */
/* @planks("I click the checkbox on the first todo") */
/* @planks("I click the checkbox on the second todo") */
/* @planks("I click the checkbox on {string}") */
/* @planks("I click the {string} checkbox") */
/* @planks("I click the {string} button") */
/* @planks("I double-click the todo's label") */
/* @planks("I change the edit input to {string}") */
/* @planks("I blur the edit input") */
/* @planks("I press Enter in the edit input") */
/* @planks("I press Escape in the edit input") */
/* @planks("I hover over the todo") */
/* @planks("I click the destroy button") */
/* @planks("I clear the edit input") */
/* @planks("the page is reloaded") */
/* @planks("the page loads") */
/* @planks("the route is {string}") */
(function () {
  'use strict';

  // Enter key code
  const ENTER_KEY = 13;
  const ESCAPE_KEY = 27;

  // Expose app functions for testing
  window.TodoApp = {};

  // Get DOM elements
  const newTodoInput = document.querySelector('.new-todo');
  const todoList = document.querySelector('.todo-list');
  const main = document.querySelector('.main');
  const footer = document.querySelector('.footer');
  const toggleAll = document.querySelector('#toggle-all');
  const todoCount = document.querySelector('.todo-count');
  const clearCompleted = document.querySelector('.clear-completed');
  const filterLinks = document.querySelectorAll('.filters a');

  // App state
  let todos = [];
  let currentFilter = 'all';

  // Load todos from localStorage
  function loadTodos() {
    const stored = localStorage.getItem('todos-todomvc');
    if (stored) {
      todos = JSON.parse(stored);
    } else {
      todos = [];
    }
    render();
  }

  // Save todos to localStorage
  function saveTodos() {
    localStorage.setItem('todos-todomvc', JSON.stringify(todos));
  }

  // Generate unique ID
  function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }

  // Create todo element
  function createTodoElement(todo) {
    const li = document.createElement('li');
    li.dataset.id = todo.id;
    li.className = todo.completed ? 'completed' : '';

    li.innerHTML = `
      <div class="view">
        <input class="toggle" type="checkbox" ${todo.completed ? 'checked' : ''}>
        <label>${escapeHtml(todo.title)}</label>
        <button class="destroy"></button>
      </div>
      <input class="edit" value="${escapeHtml(todo.title)}">
    `;

    return li;
  }

  // Escape HTML to prevent XSS
  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // Render todos
  function render() {
    // Filter todos based on current route
    const filteredTodos = todos.filter(function (todo) {
      if (currentFilter === 'active') {
        return !todo.completed;
      } else if (currentFilter === 'completed') {
        return todo.completed;
      }
      return true;
    });

    // Get existing todo elements by ID
    const existingElements = {};
    const existingElementsList = todoList.querySelectorAll('li');
    existingElementsList.forEach(function (el) {
      existingElements[el.dataset.id] = el;
    });

    // Track which IDs are still in the filtered list
    const filteredIds = {};

    // Render filtered todos, updating existing elements or creating new ones
    filteredTodos.forEach(function (todo, index) {
      filteredIds[todo.id] = true;
      let todoEl = existingElements[todo.id];

      if (todoEl) {
        // Update existing element in place
        todoEl.className = todo.completed ? 'completed' : '';
        const checkbox = todoEl.querySelector('.toggle');
        if (checkbox) {
          checkbox.checked = todo.completed;
        }
        const label = todoEl.querySelector('label');
        if (label) {
          label.textContent = escapeHtml(todo.title);
        }
        const editInput = todoEl.querySelector('.edit');
        if (editInput) {
          editInput.value = escapeHtml(todo.title);
        }
      } else {
        // Create new element
        todoEl = createTodoElement(todo);
        todoList.appendChild(todoEl);
      }
    });

    // Remove elements that are no longer in the filtered list
    existingElementsList.forEach(function (el) {
      if (!filteredIds[el.dataset.id]) {
        todoList.removeChild(el);
      }
    });

    // Update UI state
    updateUI();
  }

  // Update UI state (main, footer, counts, buttons)
  function updateUI() {
    const activeCount = todos.filter(function (todo) { return !todo.completed; }).length;
    const completedCount = todos.length - activeCount;
    const hasTodos = todos.length > 0;

    // Show/hide main and footer
    if (hasTodos) {
      main.classList.remove('hidden');
      footer.classList.remove('hidden');
    } else {
      main.classList.add('hidden');
      footer.classList.add('hidden');
    }

    // Update todo count
    const itemsText = activeCount === 1 ? 'item' : 'items';
    todoCount.innerHTML = `<strong>${activeCount}</strong> ${itemsText} left`;

    // Update toggle-all checkbox
    if (hasTodos && activeCount === 0) {
      toggleAll.checked = true;
    } else {
      toggleAll.checked = false;
    }

    // Show/hide clear completed button
    if (completedCount > 0) {
      clearCompleted.classList.remove('hidden');
      clearCompleted.style.display = 'block';
    } else {
      clearCompleted.classList.add('hidden');
      clearCompleted.style.display = 'none';
    }

    // Update filter links
    filterLinks.forEach(function (link) {
      link.classList.remove('selected');
      const href = link.getAttribute('href');
      if (href === '#/' && currentFilter === 'all') {
        link.classList.add('selected');
      } else if (href === '#/active' && currentFilter === 'active') {
        link.classList.add('selected');
      } else if (href === '#/completed' && currentFilter === 'completed') {
        link.classList.add('selected');
      }
    });
  }

  // Add new todo
  function addTodo(title) {
    const trimmedTitle = title.trim();
    if (!trimmedTitle) {
      return;
    }

    const todo = {
      id: generateId(),
      title: trimmedTitle,
      completed: false
    };

    todos.push(todo);
    saveTodos();
    render();
  }

  // Toggle todo completion
  function toggleTodo(id) {
    const todo = todos.find(function (t) { return t.id === id; });
    if (todo) {
      todo.completed = !todo.completed;
      saveTodos();
      render();
    }
  }

  // Delete todo
  function deleteTodo(id) {
    todos = todos.filter(function (t) { return t.id !== id; });
    saveTodos();
    render();
  }

  // Edit todo
  function editTodo(id, newTitle) {
    const todo = todos.find(function (t) { return t.id === id; });
    if (!todo) {
      return;
    }

    const trimmedTitle = newTitle.trim();
    if (!trimmedTitle) {
      // Empty title deletes the todo
      deleteTodo(id);
      return;
    }

    todo.title = trimmedTitle;
    saveTodos();
    render();
  }

  // Toggle all todos
  function toggleAllTodos() {
    const allCompleted = todos.every(function (todo) { return todo.completed; });
    
    todos.forEach(function (todo) {
      todo.completed = !allCompleted;
    });
    
    saveTodos();
    render();
  }

  // Clear completed todos
  function clearCompletedTodos() {
    todos = todos.filter(function (todo) { return !todo.completed; });
    saveTodos();
    render();
  }

  // Set filter from route
  function setFilter(route) {
    if (route === '#/') {
      currentFilter = 'all';
    } else if (route === '#/active') {
      currentFilter = 'active';
    } else if (route === '#/completed') {
      currentFilter = 'completed';
    }
    render();
  }

  // Event handlers
  function handleNewTodoKeydown(e) {
    if (e.keyCode === ENTER_KEY) {
      e.preventDefault();
      addTodo(newTodoInput.value);
      newTodoInput.value = '';
    }
  }

  function handleTodoListClick(e) {
    const todoEl = e.target.closest('li');
    if (!todoEl) {
      return;
    }

    const id = todoEl.dataset.id;

    // Toggle checkbox
    if (e.target.classList.contains('toggle')) {
      toggleTodo(id);
    }

    // Delete button
    if (e.target.classList.contains('destroy')) {
      deleteTodo(id);
    }
  }

  function handleTodoListDblClick(e) {
    const label = e.target.closest('label');
    if (!label) {
      return;
    }

    const todoEl = label.closest('li');
    if (todoEl) {
      todoEl.classList.add('editing');
      const editInput = todoEl.querySelector('.edit');
      if (editInput) {
        editInput.focus();
      }
    }
  }

  function handleEditKeydown(e) {
    if (!e.target.classList.contains('edit')) {
      return;
    }

    const todoEl = e.target.closest('li');
    if (!todoEl) {
      return;
    }

    const id = todoEl.dataset.id;

    if (e.keyCode === ENTER_KEY) {
      e.preventDefault();
      editTodo(id, e.target.value);
    } else if (e.keyCode === ESCAPE_KEY) {
      e.preventDefault();
      // Revert to original title
      const todo = todos.find(function (t) { return t.id === id; });
      if (todo) {
        e.target.value = todo.title;
      }
      todoEl.classList.remove('editing');
    }
  }

  function handleEditBlur(e) {
    if (!e.target.classList.contains('edit')) {
      return;
    }

    const todoEl = e.target.closest('li');
    if (!todoEl) {
      return;
    }

    const id = todoEl.dataset.id;
    editTodo(id, e.target.value);
  }

  function handleToggleAllClick(e) {
    toggleAllTodos();
  }

  function handleClearCompletedClick(e) {
    clearCompletedTodos();
  }

  function handleHashChange() {
    setFilter(window.location.hash);
  }

  // Bind event listeners
  if (newTodoInput) {
    newTodoInput.addEventListener('keydown', handleNewTodoKeydown);
  }

  if (todoList) {
    todoList.addEventListener('click', handleTodoListClick);
    todoList.addEventListener('dblclick', handleTodoListDblClick);
    todoList.addEventListener('keydown', handleEditKeydown);
    todoList.addEventListener('focusout', handleEditBlur);
  }

  if (toggleAll) {
    toggleAll.addEventListener('click', handleToggleAllClick);
  }

  if (clearCompleted) {
    clearCompleted.addEventListener('click', handleClearCompletedClick);
  }

  // Handle routing
  window.addEventListener('hashchange', handleHashChange);
  window.addEventListener('load', function () {
    handleHashChange();
  });

  // Initialize app
  loadTodos();

  // Expose functions for testing
  window.TodoApp.addTodo = addTodo;
  window.TodoApp.toggleTodo = toggleTodo;
  window.TodoApp.deleteTodo = deleteTodo;
  window.TodoApp.editTodo = editTodo;
  window.TodoApp.toggleAllTodos = toggleAllTodos;
  window.TodoApp.clearCompletedTodos = clearCompletedTodos;
  window.TodoApp.setFilter = setFilter;
  window.TodoApp.getTodos = function () { return todos; };
  window.TodoApp.setTodos = function (newTodos) { todos = newTodos; saveTodos(); render(); };
  window.TodoApp.loadTodos = loadTodos;
  window.TodoApp.saveTodos = saveTodos;
  window.TodoApp.render = render;
  window.TodoApp.updateUI = updateUI;

}());