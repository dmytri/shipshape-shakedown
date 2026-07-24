Feature: Persistence
  As a user
  I want my todos to persist across page reloads
  So that I do not lose my tasks

  Rule: Todos are saved to localStorage

  Scenario: Newly created todos are persisted to localStorage
    Given the app has loaded with no stored todos
    When the user adds a todo titled "Buy groceries"
    Then localStorage contains a record with a todo titled "Buy groceries"

  Scenario: Completed state is persisted to localStorage
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user clicks the toggle for the todo titled "Buy groceries"
    Then localStorage stores the todo "Buy groceries" as completed

  Scenario: Persisted todos are restored on reload
    Given localStorage contains a todo with title "Buy groceries" that is not completed
    When the app loads
    Then the todo list contains an item with title "Buy groceries"

  Scenario: Editing mode is not persisted
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user double-clicks the todo titled "Buy groceries"
    Then localStorage does not contain any indication of editing state

  Scenario: Destroyed todos are removed from localStorage
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
      | Walk the dog |
    When the user destroys the todo titled "Buy groceries"
    Then localStorage contains no record of a todo titled "Buy groceries"