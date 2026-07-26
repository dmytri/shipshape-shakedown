Feature: Destroy todo
  Clicking the destroy button on a todo item removes it from the list.

  Scenario: Clicking the destroy button removes the todo
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    When the user clicks the destroy button for "Buy milk"
    Then the todo list does not display "Buy milk"
    And the todo list has 0 items