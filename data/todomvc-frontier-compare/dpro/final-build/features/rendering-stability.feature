Feature: Rendering stability
  The app must update todo items in-place rather than tearing
  down and rebuilding the entire list on every change. Editing
  mode must hide the checkbox and destroy button via CSS.

  Scenario: Checkbox element survives a toggle
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    When the user marks "Buy milk" as complete
    Then "Buy milk" is marked as completed
    And the todo item for "Buy milk" remains the same DOM element

  Scenario: Toggle-all preserves individual item elements
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | false     |
      | Buy a unicorn    | false     |
    When the user clicks the toggle-all checkbox
    Then "Taste JavaScript" is marked as completed
    And "Buy a unicorn" is marked as completed
    And the todo item for "Taste JavaScript" remains the same DOM element

  Scenario: Checkbox and destroy button are hidden during editing
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    And "Buy milk" is in editing mode
    Then the checkbox for "Buy milk" is hidden
    And the destroy button for "Buy milk" is hidden
