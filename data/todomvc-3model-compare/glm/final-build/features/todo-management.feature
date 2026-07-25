Feature: Todo Management
  As a user
  I want to manage a list of todo items
  So that I can track tasks I need to complete

  Scenario: No todos hides main section and footer
    Given the app has no todos
    Then the main section should be hidden
    And the footer should be hidden

  Scenario: Adding a new todo
    Given the app has no todos
    When I enter "Buy groceries" in the new todo input
    And I press Enter
    Then a todo with title "Buy groceries" should be added to the list
    And the new todo input should be cleared
    And the main section should be visible
    And the footer should be visible

  Scenario: Adding a todo with whitespace only is ignored
    Given the app has no todos
    When I enter "   " in the new todo input
    And I press Enter
    Then no todo should be added to the list
    And the main section should remain hidden

  Scenario: Toggling a todo as complete
    Given the app has a todo "Buy groceries"
    When I click the checkbox on the todo
    Then the todo should be marked as completed
    And the todo should have the class "completed"

  Scenario: Marking all todos as complete
    Given the app has todos "Buy groceries" and "Walk the dog"
    And both todos are active
    When I click the "Mark all as complete" checkbox
    Then both todos should be marked as completed
    And the "Mark all as complete" checkbox should be checked

  Scenario: Mark all as complete updates when single todo is toggled
    Given the app has todos "Buy groceries" and "Walk the dog"
    And both todos are active
    When I click the checkbox on the first todo
    Then the "Mark all as complete" checkbox should not be checked
    When I click the checkbox on the second todo
    Then the "Mark all as complete" checkbox should be checked

  Scenario: Mark all as complete clears after clearing completed
    Given the app has completed todos "Buy groceries" and "Walk the dog"
    And the "Mark all as complete" checkbox is checked
    When I click the "Clear completed" button
    Then the "Mark all as complete" checkbox should be unchecked

  Scenario: Editing a todo by double-clicking the label
    Given the app has a todo "Buy groceries"
    When I double-click the todo's label
    Then the todo should have the class "editing"
    And the edit input should be focused
    And the edit input should contain "Buy groceries"

  Scenario: Saving an edit on blur
    Given the app has a todo "Buy groceries"
    And the todo is in edit mode
    When I change the edit input to "Buy milk and eggs"
    And I blur the edit input
    Then the todo title should be "Buy milk and eggs"
    And the todo should not have the class "editing"

  Scenario: Saving an edit on Enter
    Given the app has a todo "Buy groceries"
    And the todo is in edit mode
    When I change the edit input to "Buy milk and eggs"
    And I press Enter in the edit input
    Then the todo title should be "Buy milk and eggs"
    And the todo should not have the class "editing"

  Scenario: Cancelling an edit on Escape
    Given the app has a todo "Buy groceries"
    And the todo is in edit mode
    When I change the edit input to "Buy milk and eggs"
    And I press Escape in the edit input
    Then the todo title should remain "Buy groceries"
    And the todo should not have the class "editing"

  Scenario: Deleting a todo by clicking destroy button
    Given the app has a todo "Buy groceries"
    When I hover over the todo
    And I click the destroy button
    Then the todo should be removed from the list
    And the main section should be hidden

  Scenario: Editing to empty text destroys the todo
    Given the app has a todo "Buy groceries"
    And the todo is in edit mode
    When I clear the edit input
    And I press Enter in the edit input
    Then the todo should be removed from the list

  Scenario: Trimming whitespace on edit save
    Given the app has a todo "Buy groceries"
    And the todo is in edit mode
    When I change the edit input to "  Buy milk and eggs  "
    And I press Enter in the edit input
    Then the todo title should be "Buy milk and eggs"

  Scenario: Todo count displays correctly for single item
    Given the app has one active todo "Buy groceries"
    Then the todo count should display "1 item left"

  Scenario: Todo count displays correctly for multiple items
    Given the app has 3 active todos
    Then the todo count should display "3 items left"

  Scenario: Todo count displays zero items
    Given the app has no active todos
    Then the todo count should display "0 items left"

  Scenario: Clear completed button removes completed todos
    Given the app has completed todos "Buy groceries" and "Walk the dog"
    And the app has an active todo "Do laundry"
    When I click the "Clear completed" button
    Then the completed todos should be removed
    And the active todo should remain

  Scenario: Clear completed button is hidden when no completed todos
    Given the app has only active todos
    Then the "Clear completed" button should be hidden

  Scenario: Persistence to localStorage
    Given the app has todos "Buy groceries" and "Walk the dog"
    When the page is reloaded
    Then the todos should be restored from localStorage
    And the todos should have the same completion states

  Scenario: Editing mode is not persisted
    Given the app has a todo "Buy groceries"
    And the todo is in edit mode
    When the page is reloaded
    Then the todo should not be in edit mode

  Scenario: Toggling a todo preserves the DOM element
    Given the app has a todo "Buy groceries"
    And I save the todo element
    When I click the checkbox on the todo
    Then the todo element should not be recreated

  Scenario: Mark all as complete preserves DOM elements
    Given the app has todos "Buy groceries" and "Walk the dog"
    And both todos are active
    And I save all todo elements
    When I click the "Mark all as complete" checkbox
    Then the todo elements should not be recreated

  Scenario: Edit mode hides view controls
    Given the app has a todo "Buy groceries"
    And the todo is in edit mode
    Then the todo's view should be hidden