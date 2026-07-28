Feature: Todo core management
  As a user
  I want to add, view, and manage todos as a group
  So that I can track what I need to do

  Rule: The app chrome adapts to the presence of todos

  Scenario: Main and footer are hidden when there are no todos
    Given the app has loaded with no stored todos
    Then the "#main" section is not visible
    And the "#footer" section is not visible

  Scenario: Main and footer appear when a todo is added
    Given the app has loaded with no stored todos
    When the user adds a todo titled "Buy groceries"
    Then the "#main" section is visible
    And the "#footer" section is visible

  Rule: New todos are created from the header input

  Scenario: Adding a todo creates an item in the list
    Given the app has loaded
    When the user adds a todo titled "Buy groceries"
    Then the todo list contains an item with title "Buy groceries"
    And the new-todo input is cleared

  Scenario: Empty trimmed input does not create a todo
    Given the app has loaded
    When the user attempts to add a todo with title "   "
    Then the todo list contains no items

  Rule: The mark-all checkbox toggles every todo

  Scenario: Mark-all checkbox checks all todos
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
      | Walk the dog |
    When the user clicks the mark-all checkbox
    Then every todo item has the "completed" class

  Scenario: Mark-all checkbox unchecks all todos when all are completed
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| true      |
      | Walk the dog | true      |
    When the user clicks the mark-all checkbox
    Then no todo item has the "completed" class

  Scenario: Mark-all checkbox reflects the state of individual toggles
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
      | Walk the dog |
    When the user toggles the first todo as completed
    Then the mark-all checkbox is not checked
    When the user toggles the second todo as completed
    Then the mark-all checkbox is checked

  Rule: The counter shows the number of active todos

  Scenario: Counter shows the count of active todos
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| false     |
      | Walk the dog | true      |
    Then the todo-count displays "1 item left"

  Scenario: Counter pluralises for zero items
    Given the app has loaded with no stored todos
    Then the todo-count displays "0 items left"

  Scenario: Counter pluralises for multiple items
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
      | Walk the dog |
      | Feed the cat |
    Then the todo-count displays "3 items left"

  Rule: The clear-completed button removes completed todos

  Scenario: Clear-completed removes all completed todos
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| false     |
      | Walk the dog | true      |
    When the user clicks the clear-completed button
    Then the todo list contains only items with titles "Buy groceries"

  Scenario: Clear-completed button is hidden when no todo is completed
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    Then the clear-completed button is not visible

  Scenario: Clear-completed button is visible when at least one todo is completed
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| true      |
    Then the clear-completed button is visible