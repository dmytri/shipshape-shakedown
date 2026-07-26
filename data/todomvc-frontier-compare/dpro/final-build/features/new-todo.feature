Feature: New todo creation
  The user creates new todo items by typing in the input field
  and pressing Enter. The input is focused on page load and
  trimmed before creating.

  Scenario: Creating a new todo
    Given the todo application is loaded
    When the user adds a new todo "Buy milk"
    Then the todo list displays "Buy milk"
    And the new todo field is empty
    And the todo list has 1 item

  Scenario: New todo input is focused on page load
    Given the todo application is loaded
    Then the new todo input is focused

  Scenario Outline: Rejecting blank todo input
    Given the todo application is loaded
    When the user adds a new todo "<input>"
    Then the todo list has 0 items

    Examples:
      | input |
      |       |
      |       |