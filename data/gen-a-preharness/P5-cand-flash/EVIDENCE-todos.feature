Feature: Todo management
  A user can manage a list of todo items.

  Scenario: Main and footer are hidden when there are no todos
    Given the todo list is empty
    When the application loads
    Then "#main" is hidden
    And "#footer" is hidden

  Scenario: New todo is created on Enter
    Given the new todo input is focused
    When the user types "Buy milk" and presses Enter
    Then a new todo item "Buy milk" appears in the list
    And the input is cleared

  Scenario: Empty trimmed input does not create a todo
    Given the new todo input is focused
    When the user types "   " and presses Enter
    Then no new todo item is created

  Scenario: Mark a single todo as complete
    Given a todo item "Buy milk" exists
    When the user clicks the checkbox for "Buy milk"
    Then the todo item gains the "completed" class
    And its checkbox is checked

  Scenario: Double-clicking a todo label enters editing mode
    Given a todo item "Buy milk" exists
    When the user double-clicks the label for "Buy milk"
    Then the todo item gains the "editing" class
    And the edit input appears with the current title

  Scenario: Editing saves on blur
    Given the todo item "Buy milk" is in editing mode
    When the user changes the title to "Buy eggs" and the input loses focus
    Then the todo item title is "Buy eggs"
    And the "editing" class is removed

  Scenario: Editing saves on Enter
    Given the todo item "Buy milk" is in editing mode
    When the user changes the title to "Buy eggs" and presses Enter
    Then the todo item title is "Buy eggs"
    And the "editing" class is removed

  Scenario: Empty title during edit destroys the todo
    Given a todo item "Buy milk" exists in editing mode
    When the user clears the title and presses Enter
    Then the todo item is removed from the list

  Scenario: Escape during edit discards changes
    Given the todo item "Buy milk" is in editing mode with the title changed to "Buy eggs"
    When the user presses Escape
    Then the todo item title remains "Buy milk"
    And the "editing" class is removed

  Scenario: Mark all as complete toggles all todos
    Given todo items "Buy milk" and "Buy eggs" exist
    When the user clicks "Mark all as complete"
    Then all todo items have the "completed" class
    And the toggle-all checkbox is checked

  Scenario: Clear completed button removes completed todos
    Given a completed todo "Buy milk" and an active todo "Buy eggs" exist
    When the user clicks "Clear completed"
    Then the todo "Buy milk" is removed from the list
    And the todo "Buy eggs" remains

  Scenario: Clear completed button is hidden when no completed todos
    Given all todos are active and none are completed
    When the application renders
    Then the "Clear completed" button is hidden

  Scenario: Counter shows pluralized active count
    Given two active todo items exist
    When the application renders
    Then the todo count shows "2 items left"
    And the count is wrapped in a <strong> tag

  Scenario: Counter shows singular for one active item
    Given one active todo item exists
    When the application renders
    Then the todo count shows "1 item left"

  Scenario: Todos persist across page reload
    Given a todo item "Buy milk" exists
    When the page is reloaded
    Then the todo item "Buy milk" is still displayed

  Scenario: Filter by active todos
    Given a completed todo "Buy milk" and an active todo "Buy eggs" exist
    When the user clicks the "Active" filter
    Then only "Buy eggs" is displayed
    And "Buy milk" is hidden

  Scenario: Filter by completed todos
    Given a completed todo "Buy milk" and an active todo "Buy eggs" exist
    When the user clicks the "Completed" filter
    Then only "Buy milk" is displayed
    And "Buy eggs" is hidden

  Scenario: All filter shows all todos
    Given a completed todo "Buy milk" and an active todo "Buy eggs" exist
    When the user clicks the "All" filter
    Then both "Buy milk" and "Buy eggs" are displayed

  Scenario: App serves index.html at the project root
    Given the project root directory contains an "index.html" file
    When the file is parsed as HTML
    Then the document has a "section.todoapp" element
    And it has an input with class "new-todo"
    And it has a "section.main" with a "ul.todo-list"
    And it has a "footer.footer" with a "span.todo-count"
    And it has a script element with src "js/app.js"

  Scenario: App signals browser readiness
    Given the project root contains a file "js/app.js"
    When the file is read
    Then the content assigns the global "appHasStarted" to a truthy value
