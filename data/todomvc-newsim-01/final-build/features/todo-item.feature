Feature: Todo item interactions
  As a user
  I want to mark, edit, and remove individual todos
  So that I can manage each task independently

  Rule: Toggling a todo changes its completed state

  Scenario: Completing a todo adds the completed class
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user clicks the toggle for the todo titled "Buy groceries"
    Then the todo item "Buy groceries" has the "completed" class

  Scenario: Uncompleting a todo removes the completed class
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| true      |
    When the user clicks the toggle for the todo titled "Buy groceries"
    Then the todo item "Buy groceries" does not have the "completed" class

  Rule: The destroy button removes a todo

  Scenario: Clicking destroy removes the todo from the list
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
      | Walk the dog |
    When the user destroys the todo titled "Buy groceries"
    Then the todo list contains only items with titles "Walk the dog"

  Rule: Toggle preserves the list element identity

  Scenario: Toggling a completed state preserves its list element
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
      | Walk the dog |
    When the user captures the list element for the todo titled "Buy groceries"
    And the user clicks the toggle for the todo titled "Buy groceries"
    Then the captured element is still attached to the list
    And the captured element has the "completed" class

  Scenario: Untoggling preserves its list element
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| true      |
      | Walk the dog | false     |
    When the user captures the list element for the todo titled "Buy groceries"
    And the user clicks the toggle for the todo titled "Buy groceries"
    Then the captured element is still attached to the list
    And the captured element does not have the "completed" class

  Scenario: Mark-all preserves individual list elements
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
      | Walk the dog |
    When the user captures the list element for the todo titled "Buy groceries"
    And the user clicks the mark-all checkbox
    Then the captured element is still attached to the list
    And the captured element has the "completed" class