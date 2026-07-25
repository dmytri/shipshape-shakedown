Feature: New todo
  As someone with things to do
  I want to add new todos by typing in the input
  So that I can track tasks

  Scenario: Create a new todo
    Given the page is loaded with no todos
    When I type "Buy milk" in the new todo input and press Enter
    Then the todo list contains a todo titled "Buy milk"
    And the new todo input is empty

  Scenario: Reject empty input
    Given the page is loaded with no todos
    When I press Enter in the new todo input without typing
    Then the todo list is still empty

  Scenario: Reject whitespace-only input
    Given the page is loaded with no todos
    When I type "   " in the new todo input and press Enter
    Then the todo list is still empty
