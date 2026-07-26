Feature: Routing and filtering
  Hash-based routing filters the todo list. The active filter
  is persisted on reload.

  Scenario: All filter shows all todos
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | true      |
      | Buy a unicorn    | false     |
    When the user navigates to "#/"
    Then the todo list displays "Taste JavaScript"
    And the todo list displays "Buy a unicorn"
    And the "All" filter is selected

  Scenario: Active filter shows only active todos
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | true      |
      | Buy a unicorn    | false     |
    When the user navigates to "#/active"
    Then the todo list does not display "Taste JavaScript"
    And the todo list displays "Buy a unicorn"
    And the "Active" filter is selected

  Scenario: Completed filter shows only completed todos
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | true      |
      | Buy a unicorn    | false     |
    When the user navigates to "#/completed"
    Then the todo list displays "Taste JavaScript"
    And the todo list does not display "Buy a unicorn"
    And the "Completed" filter is selected

  Scenario: Active filter persists on reload
    Given the todo application is loaded
    And the user has navigated to "#/active"
    When the user reloads the page
    Then the "Active" filter is selected

  Scenario: Completing an item hides it from the active filter
    Given the todo application is loaded
    And the todo list has the following items:
      | title        | completed |
      | Buy a unicorn | false     |
    And the user has navigated to "#/active"
    When the user marks "Buy a unicorn" as complete
    Then the todo list does not display "Buy a unicorn"