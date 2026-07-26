Feature: Editing a todo
  When editing mode is active, the user can save changes on
  Enter or blur, cancel on Escape, or destroy the todo by
  clearing the input and saving.

  Scenario: Saving an edit on Enter
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    And "Buy milk" is in editing mode
    When the user changes the edit value to "Buy oat milk" and presses Enter
    Then the todo list displays "Buy oat milk"
    And "Buy oat milk" is not in editing mode

  Scenario: Saving an edit on blur
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    And "Buy milk" is in editing mode
    When the user changes the edit value to "Buy oat milk" and clicks outside
    Then the todo list displays "Buy oat milk"
    And "Buy oat milk" is not in editing mode

  Scenario: Cancelling an edit on Escape
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    And "Buy milk" is in editing mode
    When the user changes the edit value to "Buy oat milk" and presses Escape
    Then the todo list displays "Buy milk"
    And "Buy milk" is not in editing mode

  Scenario: Empty edit destroys the todo
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    And "Buy milk" is in editing mode
    When the user clears the edit value and presses Enter
    Then the todo list has 0 items
    And the todo list does not display "Buy milk"