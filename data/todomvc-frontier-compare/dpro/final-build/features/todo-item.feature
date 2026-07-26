Feature: Todo item interactions
  Each todo item supports three interactions: toggling its
  completed state, activating editing mode by double-click,
  and showing a destroy button on hover.

  Scenario: Mark a todo as complete
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    When the user marks "Buy milk" as complete
    Then "Buy milk" is marked as completed

  Scenario: Mark a completed todo as active
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | true      |
    When the user marks "Buy milk" as active
    Then "Buy milk" is not marked as completed

  Scenario: Activate editing by double-click
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | false     |
    When the user double-clicks the label for "Buy milk"
    Then "Buy milk" is in editing mode
    And the edit field for "Buy milk" contains "Buy milk"
    And the edit field for "Buy milk" is focused