Feature: Delete todo
  As someone with things to do
  I want to remove individual todos and clear completed ones
  So that I can keep my list tidy

  Scenario: Delete a todo with the destroy button
    Given the page is loaded with a todo "Buy milk" that is not completed
    When I click the destroy button for the todo "Buy milk"
    Then the todo list does not contain a todo titled "Buy milk"

  Scenario: Clear completed removes all completed todos
    Given the page is loaded with a completed todo "Buy milk" and an active todo "Walk the dog"
    When I click the clear completed button
    Then the todo list does not contain a todo titled "Buy milk"
    And the todo list contains a todo titled "Walk the dog"

  Scenario: Clear completed button is hidden when no completed todos
    Given the page is loaded with an active todo "Walk the dog" and no completed todos
    Then the clear completed button is not visible

  Scenario: Hide main and footer when no todos remain
    Given the page is loaded with no todos
    Then the main section is hidden
    And the footer is hidden
