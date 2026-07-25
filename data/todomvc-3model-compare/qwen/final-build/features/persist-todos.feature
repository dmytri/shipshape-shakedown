Feature: Persist todos
  As someone with things to do
  I want my todos to persist across page reloads
  So that I do not lose my list

  Scenario: Todos persist to localStorage
    Given the page is loaded with no todos
    When I type "Buy milk" in the new todo input and press Enter
    And I reload the page
    Then the todo list contains a todo titled "Buy milk"
    And the todo has the key "id", the key "title" with value "Buy milk", and the key "completed"

  Scenario: Completed state persists
    Given the page is loaded with a completed todo "Buy milk"
    When I reload the page
    Then the todo "Buy milk" has the class "completed"

  Scenario: Editing mode is not persisted
    Given the page is loaded with a todo "Buy milk" in edit mode
    When I reload the page
    Then the todo "Buy milk" does not have the class "editing"
