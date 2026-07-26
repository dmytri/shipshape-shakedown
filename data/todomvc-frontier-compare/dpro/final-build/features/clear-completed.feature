Feature: Clear completed
  The clear-completed button removes all completed todos.
  It is hidden when there are no completed todos.

  Scenario: Clear completed removes completed todos
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | true      |
      | Buy a unicorn    | false     |
    When the user clicks "Clear completed"
    Then the todo list does not display "Taste JavaScript"
    And the todo list displays "Buy a unicorn"
    And the todo list has 1 item

  Scenario: Clear completed button hidden when no completed todos
    Given the todo application is loaded
    And the todo list has the following items:
      | title        | completed |
      | Buy a unicorn | false     |
    Then the clear completed button is hidden