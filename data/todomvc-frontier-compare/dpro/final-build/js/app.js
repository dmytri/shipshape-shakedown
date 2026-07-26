/**
 * TodoMVC application
 */
(function () {
  "use strict";

  var STORAGE_KEY = "todos-vanilla";
  var ENTER_KEY = 13;
  var ESCAPE_KEY = 27;

  function getTodos() {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
    } catch (e) {
      return [];
    }
  }

  function setTodos(todos) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(todos));
  }

  /**
   * @planks("the toggle-all checkbox is checked")
   * @planks("the toggle-all checkbox is not checked")
   */
  function updateToggleAll() {
    var todos = getTodos();
    var toggleAll = document.querySelector("#toggle-all");
    if (todos.length === 0) {
      toggleAll.checked = false;
    } else {
      toggleAll.checked = todos.every(function (t) { return t.completed; });
    }
  }

  /**
   * @planks("the counter shows {string}")
   */
  function updateCounter() {
    var todos = getTodos();
    var activeCount = todos.filter(function (t) { return !t.completed; }).length;
    var countEl = document.querySelector(".todo-count");
    var word = activeCount === 1 ? "item" : "items";
    countEl.innerHTML = "<strong>" + activeCount + "</strong> " + word + " left";
  }

  /**
   * @planks("the clear completed button is hidden")
   */
  function updateClearCompleted() {
    var todos = getTodos();
    var hasCompleted = todos.some(function (t) { return t.completed; });
    var btn = document.querySelector(".clear-completed");
    btn.style.display = hasCompleted ? "" : "none";
  }

  function getCurrentFilter() {
    var hash = location.hash;
    if (hash === "#/active") return "active";
    if (hash === "#/completed") return "completed";
    return "all";
  }

  /**
   * @planks("the {string} filter is selected")
   * @planks("the user navigates to {string}")
   */
  function updateFilterUI() {
    var filter = getCurrentFilter();
    var links = document.querySelectorAll(".filters a");
    for (var i = 0; i < links.length; i++) {
      links[i].classList.remove("selected");
    }
    var selectedLink = document.querySelector(".filters a[href='" + location.hash + "']");
    if (!selectedLink) {
      selectedLink = document.querySelector(".filters a[href='#/']");
    }
    if (selectedLink) {
      selectedLink.classList.add("selected");
    }
  }

  /**
   * @planks("the todo list displays {string}")
   * @planks("the todo list does not display {string}")
   * @planks("the todo list has {int} item")
   * @planks("the todo list has {int} items")
   * @planks("the main section is hidden")
   * @planks("the main section is visible")
   * @planks("the footer is hidden")
   * @planks("the footer is visible")
   * @planks("the edit field for {string} contains {string}")
   */
  function makeTodoElement(todo) {
    var li = document.createElement("li");
    li.setAttribute("data-id", todo.id);
    if (todo.completed) {
      li.className = "completed";
    }

    var viewDiv = document.createElement("div");
    viewDiv.className = "view";

    var toggle = document.createElement("input");
    toggle.className = "toggle";
    toggle.type = "checkbox";
    toggle.checked = todo.completed;

    var label = document.createElement("label");
    label.textContent = todo.title;

    var destroyBtn = document.createElement("button");
    destroyBtn.className = "destroy";

    viewDiv.appendChild(toggle);
    viewDiv.appendChild(label);
    viewDiv.appendChild(destroyBtn);

    var editInput = document.createElement("input");
    editInput.className = "edit";
    editInput.value = todo.title;

    li.appendChild(viewDiv);
    li.appendChild(editInput);
    return li;
  }

  /**
   * @planks("the todo list displays {string}")
   * @planks("the todo list does not display {string}")
   * @planks("the todo list has {int} item")
   * @planks("the todo list has {int} items")
   * @planks("the main section is hidden")
   * @planks("the main section is visible")
   * @planks("the footer is hidden")
   * @planks("the footer is visible")
   * @planks("the edit field for {string} contains {string}")
   */
  function render() {
    var todos = getTodos();
    var filter = getCurrentFilter();
    var list = document.querySelector(".todo-list");
    var main = document.querySelector(".main");
    var footer = document.querySelector(".footer");

    // Filter todos based on route
    var filteredTodos = todos;
    if (filter === "active") {
      filteredTodos = todos.filter(function (t) { return !t.completed; });
    } else if (filter === "completed") {
      filteredTodos = todos.filter(function (t) { return t.completed; });
    }

    // Build a set of ids that should be visible
    var visibleIds = {};
    for (var i = 0; i < filteredTodos.length; i++) {
      visibleIds[filteredTodos[i].id] = true;
    }

    // Remove template items (no data-id) and index existing items
    var existing = {};
    var existingItems = list.querySelectorAll("li");
    for (var i = 0; i < existingItems.length; i++) {
      var id = existingItems[i].getAttribute("data-id");
      if (id) {
        existing[id] = existingItems[i];
      } else {
        // Template item from base HTML — remove it
        list.removeChild(existingItems[i]);
      }
    }

    // Update or insert, preserving order
    var nextSibling = null;
    for (var i = filteredTodos.length - 1; i >= 0; i--) {
      var todo = filteredTodos[i];
      var li = existing[todo.id];
      if (li) {
        // Update existing element in-place
        if (todo.completed) {
          li.classList.add("completed");
        } else {
          li.classList.remove("completed");
        }
        li.querySelector(".toggle").checked = todo.completed;
        var label = li.querySelector("label");
        if (label.textContent !== todo.title) {
          label.textContent = todo.title;
        }
        var editInput = li.querySelector(".edit");
        if (editInput.value !== todo.title) {
          editInput.value = todo.title;
        }
        // Place in correct order
        if (li.nextSibling !== nextSibling) {
          list.insertBefore(li, nextSibling);
        }
        // Remove from existing map so we know it was handled
        delete existing[todo.id];
      } else {
        // Create new element
        li = makeTodoElement(todo);
        list.insertBefore(li, nextSibling);
      }
      nextSibling = li;
    }

    // Remove any leftover existing items (no longer in filtered set)
    for (var id in existing) {
      if (Object.prototype.hasOwnProperty.call(existing, id)) {
        list.removeChild(existing[id]);
      }
    }

    // Show/hide main and footer
    if (todos.length === 0) {
      main.style.display = "none";
      footer.style.display = "none";
    } else {
      main.style.display = "";
      footer.style.display = "";
    }

    updateToggleAll();
    updateCounter();
    updateClearCompleted();
    updateFilterUI();
  }

  /**
   * @planks("the user adds a new todo {string}")
   */
  function addTodo(title) {
    var todos = getTodos();
    todos.push({
      id: Date.now().toString(),
      title: title,
      completed: false,
    });
    setTodos(todos);
    render();
  }

  /**
   * @planks("the new todo field is empty")
   */
  function onNewTodoKeydown(event) {
    if (event.keyCode !== ENTER_KEY) return;
    var input = event.target;
    var title = input.value.trim();
    if (title === "") return;
    addTodo(title);
    input.value = "";
  }

  function findTodoById(id) {
    var todos = getTodos();
    for (var i = 0; i < todos.length; i++) {
      if (todos[i].id === id) return i;
    }
    return -1;
  }

  /**
   * @planks("the user marks {string} as complete")
   * @planks("the user marks {string} as active")
   * @planks("{string} is marked as completed")
   * @planks("{string} is not marked as completed")
   */
  function onToggleClick(event) {
    var li = event.target.closest("li");
    var id = li.getAttribute("data-id");
    var idx = findTodoById(id);
    if (idx === -1) return;
    var todos = getTodos();
    todos[idx].completed = !todos[idx].completed;
    setTodos(todos);
    render();
  }

  /**
   * @planks("the user clicks the toggle-all checkbox")
   */
  function onToggleAllClick() {
    var toggleAll = document.querySelector("#toggle-all");
    var todos = getTodos();
    var newState = toggleAll.checked;
    for (var i = 0; i < todos.length; i++) {
      todos[i].completed = newState;
    }
    setTodos(todos);
    render();
  }

  /**
   * @planks("the user double-clicks the label for {string}")
   * @planks("{string} is in editing mode")
   * @planks("the edit field for {string} is focused")
   */
  function onDoubleClick(event) {
    var label = event.target;
    if (label.tagName !== "LABEL") return;
    var li = label.closest("li");
    li.classList.add("editing");
    var editInput = li.querySelector(".edit");
    editInput.focus();
  }

  /**
   * @planks("the user changes the edit value to {string} and presses Enter")
   * @planks("the user changes the edit value to {string} and presses Escape")
   * @planks("the user clears the edit value and presses Enter")
   * @planks("{string} is not in editing mode")
   */
  function onEditKeydown(event) {
    var editInput = event.target;
    var li = editInput.closest("li");
    var id = li.getAttribute("data-id");
    var idx = findTodoById(id);
    if (idx === -1) return;

    if (event.keyCode === ENTER_KEY) {
      var newTitle = editInput.value.trim();
      if (newTitle === "") {
        // Destroy todo
        var todos = getTodos();
        todos.splice(idx, 1);
        setTodos(todos);
        render();
      } else {
        var todos = getTodos();
        todos[idx].title = newTitle;
        setTodos(todos);
        li.classList.remove("editing");
        render();
      }
    } else if (event.keyCode === ESCAPE_KEY) {
      // Cancel - revert the edit input to original title
      var todos = getTodos();
      editInput.value = todos[idx].title;
      li.classList.remove("editing");
    }
  }

  /**
   * @planks("the user changes the edit value to {string} and clicks outside")
   * @planks("{string} is not in editing mode")
   */
  function onEditBlur(event) {
    var editInput = event.target;
    var li = editInput.closest("li");
    if (!li.classList.contains("editing")) return;
    var id = li.getAttribute("data-id");
    var idx = findTodoById(id);
    if (idx === -1) return;
    var newTitle = editInput.value.trim();
    if (newTitle === "") {
      var todos = getTodos();
      todos.splice(idx, 1);
      setTodos(todos);
      render();
    } else {
      var todos = getTodos();
      todos[idx].title = newTitle;
      setTodos(todos);
      li.classList.remove("editing");
      render();
    }
  }

  /**
   * @planks("the user clicks {string}")
   */
  function onClearCompletedClick() {
    var todos = getTodos().filter(function (t) { return !t.completed; });
    setTodos(todos);
    render();
  }

  /**
   * @planks("the user clicks the destroy button for {string}")
   */
  function onDestroyClick(event) {
    var li = event.target.closest("li");
    var id = li.getAttribute("data-id");
    var idx = findTodoById(id);
    if (idx === -1) return;
    var todos = getTodos();
    todos.splice(idx, 1);
    setTodos(todos);
    render();
  }

  // Delegated event listeners on the todo list
  var todoList = document.querySelector(".todo-list");

  // Toggle individual todo
  todoList.addEventListener("change", function (event) {
    if (event.target.className === "toggle") {
      onToggleClick(event);
    }
  });

  // Double-click to edit
  todoList.addEventListener("dblclick", function (event) {
    onDoubleClick(event);
  });

  // Edit keydown (Enter to save, Escape to cancel)
  todoList.addEventListener("keydown", function (event) {
    if (event.target.className === "edit") {
      onEditKeydown(event);
    }
  });

  // Edit blur (save on blur)
  todoList.addEventListener("blur", function (event) {
    if (event.target.className === "edit") {
      onEditBlur(event);
    }
  }, true);

  // Destroy todo
  todoList.addEventListener("click", function (event) {
    if (event.target.className === "destroy") {
      onDestroyClick(event);
    }
  });

  // New todo input
  var newTodoInput = document.querySelector(".new-todo");
  if (newTodoInput) {
    newTodoInput.addEventListener("keydown", onNewTodoKeydown);
  }

  // Toggle-all
  var toggleAll = document.querySelector("#toggle-all");
  if (toggleAll) {
    toggleAll.addEventListener("click", onToggleAllClick);
  }

  // Clear completed
  var clearCompleted = document.querySelector(".clear-completed");
  if (clearCompleted) {
    clearCompleted.addEventListener("click", onClearCompletedClick);
  }

  // Routing
  window.addEventListener("hashchange", function () {
    render();
  });

  render();
})();