Feature: Todo Management
  As a user
  I want to manage a todo list
  So that I can keep track of my tasks

  Background:
    Given the app is rendered fresh

  Rule: No todos

  Scenario: The main and footer sections are hidden when there are no todos
    Given the app has no todos
    Then the main section is not visible
    And the footer section is not visible

  Rule: Creating new todos

  Scenario: A user creates a new todo
    Given the new-todo input is focused
    When the user types "Buy groceries" into the new-todo input and presses Enter
    Then a todo item with the title "Buy groceries" appears in the todo list
    And the new-todo input is cleared

  Scenario: A user cannot create an empty todo
    Given the new-todo input contains whitespace only
    When the user presses Enter
    Then no new todo item is created

  Scenario: Multiple todos are appended in order
    Given the following todos exist:
      | title          |
      | First task     |
      | Second task    |
    When the user creates a todo with title "Third task"
    Then the todo list contains exactly 3 items
    And the last item in the list has the title "Third task"

  Rule: Marking todos as completed

  Scenario: A user marks a single todo as completed
    Given a todo with title "Walk the dog" exists
    When the user clicks the toggle checkbox for "Walk the dog"
    Then the todo "Walk the dog" has the completed class
    And its checkbox is checked

  Scenario: Toggling a todo updates the row in place without rebuilding the list
    Given a todo with title "Walk the dog" exists
    When the user captures the todo list element reference
    And the user clicks the toggle checkbox for "Walk the dog"
    Then the captured todo list element is still attached to the DOM

  Scenario: A user unmarks a completed todo
    Given a completed todo with title "Walk the dog" exists
    When the user clicks the toggle checkbox for "Walk the dog"
    Then the todo "Walk the dog" does not have the completed class
    And its checkbox is not checked

  Scenario: Mark all todos as completed
    Given the following todos exist:
      | title       |
      | Task one    |
      | Task two    |
    When the user clicks the toggle-all checkbox
    Then all todos have the completed class
    And the toggle-all checkbox is checked

  Scenario: Toggle-all unchecks when all items are individually unchecked
    Given all todos are completed
    When the user unchecks every todo individually
    Then the toggle-all checkbox is not checked

  Scenario: Toggle-all checkbox updates when individual todos change
    Given the following todos exist:
      | title       |
      | Task one    |
      | Task two    |
    When the user marks "Task one" as completed
    And the user marks "Task two" as completed
    Then the toggle-all checkbox is checked

  Rule: Clear completed

  Scenario: Clear completed button removes completed todos
    Given the following todos exist:
      | title       | completed |
      | Task one    | true      |
      | Task two    | false     |
    When the user clicks the clear-completed button
    Then only 1 todo remains in the list
    And the remaining todo has the title "Task two"

  Scenario: Clear completed button is hidden when no todos are completed
    Given a todo with title "Active task" exists
    And no todos are completed
    Then the clear-completed button is not visible

  Scenario: Clear completed button appears when a todo is completed
    Given a todo with title "Task" exists
    When the user marks "Task" as completed
    Then the clear-completed button is visible

  Rule: Todo counter

  Scenario: Counter shows the number of active todos
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | true      |
      | Task three  | false     |
    Then the todo-count displays "2 items left"

  Scenario: Counter shows singular "item" for one active todo
    Given the following todos exist:
      | title    | completed |
      | Task one | false     |
      | Task two | true      |
    Then the todo-count displays "1 item left"

  Scenario: Counter shows "0 items left" when all todos are completed
    Given the following todos exist:
      | title    | completed |
      | Task one | true      |
    Then the todo-count displays "0 items left"

  Rule: Editing todos

  Scenario: A user enters edit mode by double-clicking a todo label
    Given a todo with title "Read a book" exists
    When the user double-clicks the label of "Read a book"
    Then the todo item has the editing class
    And the edit input contains "Read a book"
    And the edit input is focused

  Scenario: View controls are hidden while editing a todo
    Given a todo with title "Read a book" exists
    When the user double-clicks the label of "Read a book"
    Then the checkbox of the editing todo is not visible
    And the destroy button of the editing todo is not visible
    And the label of the editing todo is not visible

  Scenario: A user saves an edit by pressing Enter
    Given the todo "Read a book" is in editing mode
    When the user changes the edit input to "Read two books" and presses Enter
    Then the todo item does not have the editing class
    And the todo label reads "Read two books"

  Scenario: A user saves an edit on blur
    Given the todo "Read a book" is in editing mode
    When the edit input loses focus
    Then the todo item does not have the editing class
    And the todo label reads "Read a book"

  Scenario: A user discards an edit by pressing Escape
    Given the todo "Read a book" is in editing mode
    And the edit input has been changed to "Changed text"
    When the user presses Escape
    Then the edit input content is discarded
    And the todo label reads "Read a book"
    And the todo item does not have the editing class

  Scenario: A trimmed empty edit destroys the todo
    Given the todo "Read a book" is in editing mode
    When the user clears the edit input and presses Enter
    Then the todo "Read a book" is removed from the list

  Rule: Destroying todos

  Scenario: A user removes a todo by clicking the destroy button
    Given a todo with title "Temp task" exists
    When the user clicks the destroy button for "Temp task"
    Then the todo "Temp task" is removed from the list

  Rule: Filtering by route

  Scenario: The default route shows all todos
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | true      |
    When the app is at the "#/" route
    Then the todo list shows 2 items

  Scenario: The active route shows only active todos
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | true      |
    When the app navigates to "#/active"
    Then the todo list shows 1 active item
    And the "Active" filter link has the selected class

  Scenario: The completed route shows only completed todos
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | true      |
    When the app navigates to "#/completed"
    Then the todo list shows 1 completed item
    And the "Completed" filter link has the selected class

  Scenario: An item completed while in a filtered view is hidden
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | false     |
    When the app navigates to "#/active"
    And the user marks "Task one" as completed
    Then the active todo list does not include "Task one"

  Scenario: The selected filter is persisted on reload
    Given the app navigates to "#/active"
    When the app is reloaded
    Then the todo list shows only active items
    And the "Active" filter link has the selected class

  Rule: Browser history navigation

  Scenario: Back returns to the previous filter
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | true      |
    When the app navigates to "#/active"
    And the app navigates to "#/completed"
    And the browser navigates back
    Then the todo list shows only active items
    And the "Active" filter link has the selected class

  Scenario: Forward redoes the filter after back
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | true      |
    When the app navigates to "#/active"
    And the app navigates to "#/completed"
    And the browser navigates back
    And the browser navigates forward
    Then the todo list shows only completed items
    And the "Completed" filter link has the selected class

  Rule: Persistence

  Scenario: Todos persist across page reloads
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | true      |
    When the app is reloaded
    Then the todo list shows 2 items
    And the todo "Task two" has the completed class

  Scenario: Completed state persists across reloads
    Given the following todos exist:
      | title       | completed |
      | Task one    | false     |
      | Task two    | true      |
    When the app is reloaded
    Then the todo "Task one" does not have the completed class
    And the todo "Task two" has the completed class