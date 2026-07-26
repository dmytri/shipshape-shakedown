Feature: Persistence
  The todo list persists to localStorage under the key
  "todos-vanilla". Editing mode is not persisted.

  Scenario: Todos survive a page reload
    Given the todo application is loaded
    And the user has added a new todo "Buy milk"
    When the user reloads the page
    Then the todo list displays "Buy milk"

  Scenario: Editing mode is not persisted across reload
    Given the todo application is loaded
    And the user has added a new todo "Buy milk"
    And the user has double-clicked the label for "Buy milk"
    When the user reloads the page
    Then "Buy milk" is not in editing mode