(function () {
  'use strict';

  var ENTER_KEY = 13;
  var ESCAPE_KEY = 27;
  var STORAGE_KEY = 'todos-todomvc';

  // ─── Model ───

/** @planks("a todo item {string} exists") @planks("a completed todo item {string} exists") @planks("an active todo item {string} exists") @planks("todo items {string} and {string} exist") @planks("todo items {string} and {string} and {string} exist") @planks("active todo items {string} and {string} exist") @planks("completed todo items {string} and {string} exist") @planks("{string} is completed") */
  function TodoModel(storageKey) {
    this.storageKey = storageKey || STORAGE_KEY;
    this.todos = this.load();
  }

  TodoModel.prototype.load = function () {
    var data;
    try {
      data = JSON.parse(localStorage.getItem(this.storageKey) || '[]');
    } catch (e) {
      data = [];
    }
    return data;
  };

  TodoModel.prototype.save = function () {
    localStorage.setItem(this.storageKey, JSON.stringify(this.todos));
  };

  TodoModel.prototype.add = function (title) {
    var todo = {
      id: Date.now() + Math.random(),
      title: title,
      completed: false
    };
    this.todos.push(todo);
    this.save();
    return todo;
  };

  TodoModel.prototype.remove = function (id) {
    this.todos = this.todos.filter(function (t) { return t.id !== id; });
    this.save();
  };

  TodoModel.prototype.toggle = function (id) {
    var todo = this.todos.filter(function (t) { return t.id === id; })[0];
    if (todo) {
      todo.completed = !todo.completed;
      this.save();
    }
  };

  TodoModel.prototype.toggleAll = function (completed) {
    this.todos.forEach(function (t) { t.completed = completed; });
    this.save();
  };

  TodoModel.prototype.update = function (id, title) {
    var todo = this.todos.filter(function (t) { return t.id === id; })[0];
    if (todo) {
      todo.title = title;
      this.save();
    }
  };

  TodoModel.prototype.clearCompleted = function () {
    this.todos = this.todos.filter(function (t) { return !t.completed; });
    this.save();
  };

  TodoModel.prototype.getActive = function () {
    return this.todos.filter(function (t) { return !t.completed; });
  };

  TodoModel.prototype.getCompleted = function () {
    return this.todos.filter(function (t) { return t.completed; });
  };

  // ─── View ───

/** @planks("I type {string} into the new-todo input and press Enter") @planks("I create a new todo {string}") @planks("the new-todo input is cleared") @planks("no new todo item is created") @planks("I click the toggle checkbox on {string}") @planks("I mark {string} as completed") @planks("I unmark {string}") @planks("I click the {string} checkbox") @planks("I click the {string} button") @planks("I click the destroy button on {string}") @planks("I double-click the label of {string}") @planks("I change the edit input to {string} and press Enter") @planks("I change the edit input to {string} and press Tab to blur") @planks("I change the edit input to {string} and press Escape") @planks("I clear the edit input and press Enter") @planks("the page is reloaded") @planks("I navigate to route {string}") @planks("the app is at route {string}") */
  function TodoView(model) {
    this.model = model;
    this.$newTodo = document.querySelector('.new-todo');
    this.$toggleAll = document.querySelector('.toggle-all');
    this.$todoList = document.querySelector('.todo-list');
    this.$footer = document.querySelector('.footer');
    this.$main = document.querySelector('.main');
    this.$todoCount = document.querySelector('.todo-count');
    this.$clearCompleted = document.querySelector('.clear-completed');
    this.$filters = document.querySelectorAll('.filters a');

    this.currentFilter = 'all';
    this.editingId = null;

    this.bindEvents();
    this.render();
  }

  TodoView.prototype.bindEvents = function () {
    var self = this;

    // New todo
    this.$newTodo.addEventListener('keypress', function (e) {
      if (e.keyCode === ENTER_KEY || e.key === 'Enter') {
        var title = self.$newTodo.value.trim();
        if (title) {
          self.model.add(title);
          self.$newTodo.value = '';
          self.render();
        }
      }
    });

    // Toggle all
    this.$toggleAll.addEventListener('change', function () {
      var completed = self.$toggleAll.checked;
      self.model.toggleAll(completed);
      self.render();
    });

    // Todo list events (delegation)
    this.$todoList.addEventListener('click', function (e) {
      var li = self._getLi(e.target);
      if (!li) return;

      // Toggle checkbox
      if (e.target.classList.contains('toggle')) {
        var id = Number(li.dataset.id);
        self.model.toggle(id);
        self.render();
      }

      // Destroy button
      if (e.target.classList.contains('destroy')) {
        var id = Number(li.dataset.id);
        self.model.remove(id);
        self.render();
      }
    });

    // Double-click to edit
    this.$todoList.addEventListener('dblclick', function (e) {
      var label = e.target;
      if (label.tagName !== 'LABEL') return;
      var li = self._getLi(label);
      if (!li) return;

      self._enterEditMode(li);
    });

    // Edit events (delegation)
    this.$todoList.addEventListener('keydown', function (e) {
      if (self.editingId === null) return;
      var input = e.target;
      if (!input.classList.contains('edit')) return;

      if (e.keyCode === ENTER_KEY || e.key === 'Enter') {
        e.preventDefault();
        self._finishEdit(input);
      } else if (e.keyCode === ESCAPE_KEY || e.key === 'Escape') {
        self._cancelEdit(input);
      }
    });

    // Blur saves edit
    this.$todoList.addEventListener('focusout', function (e) {
      if (self.editingId === null) return;
      var input = e.target;
      if (!input.classList.contains('edit')) return;
      self._finishEdit(input);
    });

    // Clear completed
    this.$clearCompleted.addEventListener('click', function () {
      self.model.clearCompleted();
      self.render();
    });

    // Hash change (routing)
    window.addEventListener('hashchange', function () {
      self._setFilterFromHash();
      self.render();
    });
  };

  TodoView.prototype._getLi = function (el) {
    while (el && el.tagName !== 'LI') {
      el = el.parentNode;
    }
    return el;
  };

  TodoView.prototype._enterEditMode = function (li) {
    var id = Number(li.dataset.id);
    this.editingId = id;
    this.render();

    var editInput = li.querySelector('.edit');
    if (editInput) {
      editInput.focus();
      editInput.setSelectionRange(editInput.value.length, editInput.value.length);
    }
  };

  TodoView.prototype._finishEdit = function (input, fromKeydown) {
    var li = this._getLi(input);
    if (!li) {
      // called from blur, li might still be live
      li = input.closest ? input.closest('li') : null;
      if (!li) return;
    }

    var id = Number(li.dataset.id);
    var title = input.value.trim();

    if (title) {
      this.model.update(id, title);
    } else {
      this.model.remove(id);
    }

    this.editingId = null;
    this.render();
  };

  TodoView.prototype._cancelEdit = function (input) {
    var li = this._getLi(input);
    if (!li) return;
    var id = Number(li.dataset.id);
    var todo = this.model.todos.filter(function (t) { return t.id === id; })[0];
    if (todo) {
      input.value = todo.title;
    }
    this.editingId = null;
    this.render();
  };

  TodoView.prototype._setFilterFromHash = function () {
    var hash = window.location.hash.replace('#/', '') || 'all';
    if (hash === '') hash = 'all';
    this.currentFilter = hash;
  };

  TodoView.prototype.render = function () {
    // Set filter from hash on initial render
    if (!this._filterSet) {
      this._setFilterFromHash();
      this._filterSet = true;
    }

    var todos = this.model.todos;
    var activeCount = this.model.getActive().length;
    var completedCount = this.model.getCompleted().length;
    var hasTodos = todos.length > 0;

    // Toggle main and footer visibility
    this.$main.style.display = hasTodos ? 'block' : 'none';
    this.$footer.style.display = hasTodos ? 'block' : 'none';

    // Toggle-all state
    this.$toggleAll.checked = hasTodos && activeCount === 0;

    // Clear completed visibility
    this.$clearCompleted.style.display = completedCount > 0 ? 'block' : 'none';

    // Filtered list
    var filtered;
    if (this.currentFilter === 'active') {
      filtered = this.model.getActive();
    } else if (this.currentFilter === 'completed') {
      filtered = this.model.getCompleted();
    } else {
      filtered = todos;
    }

    // Build list — reuse existing <li> elements by data-id to preserve element identity
    var existing = {};
    Array.from(this.$todoList.children).forEach(function (li) {
      existing[li.dataset.id] = li;
    });

    var fragment = document.createDocumentFragment();
    filtered.forEach(function (todo) {
      var li = existing[todo.id];
      if (li) {
        delete existing[todo.id];
      } else {
        li = document.createElement('li');
        li.innerHTML = '<div class="view"><input class="toggle" type="checkbox"><label></label><button class="destroy"></button></div><input class="edit" style="display:none">';
      }

      li.dataset.id = todo.id;

      var liClass = '';
      if (todo.completed) liClass += 'completed ';
      if (this.editingId === todo.id) liClass += 'editing';
      li.className = liClass.trim();

      var toggle = li.querySelector('.toggle');
      toggle.checked = !!todo.completed;

      var label = li.querySelector('label');
      label.textContent = todo.title;

      var edit = li.querySelector('.edit');
      edit.value = todo.title;
      edit.style.display = this.editingId === todo.id ? '' : 'none';

      var view = li.querySelector('.view');
      view.style.display = this.editingId === todo.id ? 'none' : '';

      fragment.appendChild(li);
    }, this);

    // Remove stale items no longer in the filtered list
    Object.keys(existing).forEach(function (id) {
      existing[id].parentNode.removeChild(existing[id]);
    });

    this.$todoList.innerHTML = '';
    this.$todoList.appendChild(fragment);

    // Focus edit input if editing
    if (this.editingId !== null) {
      var editInput = this.$todoList.querySelector('.editing .edit');
      if (editInput && document.activeElement !== editInput) {
        editInput.focus();
        editInput.setSelectionRange(editInput.value.length, editInput.value.length);
      }
    }

    // Todo count
    var countText = activeCount + ' item';
    if (activeCount !== 1) countText += 's';
    countText += ' left';
    this.$todoCount.innerHTML = '<strong>' + activeCount + '</strong> ' + countText.slice(countText.indexOf(' ') + 1);

    // Filter link selection
    this.$filters.forEach(function (a) {
      var href = a.getAttribute('href').replace('#/', '') || 'all';
      if (href === '') href = 'all';
      if (href === this.currentFilter) {
        a.classList.add('selected');
      } else {
        a.classList.remove('selected');
      }
    }, this);
  };

  TodoView.prototype._escapeHtml = function (str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  };

  // ─── Bootstrap ───

  var model = new TodoModel();
  var view = new TodoView(model);
})();