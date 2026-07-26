Feature: Todo list display
  The application shows or hides the main section and footer
  depending on whether todos exist.

  Scenario: Empty todo list hides main and footer
    Given the todo application is loaded
    And there are no todos
    Then the main section is hidden
    And the footer is hidden

  Scenario: Todo list with items shows main and footer
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | false     |
    Then the main section is visible
    And the footer is visible