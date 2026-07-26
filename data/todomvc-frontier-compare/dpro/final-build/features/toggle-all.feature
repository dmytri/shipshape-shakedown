Feature: Toggle all
  The toggle-all checkbox sets all todos to the same completed
  state. It updates when individual items change and clears
  after the clear-completed action.

  Scenario: Mark all todos as complete
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | false     |
      | Buy a unicorn    | false     |
    When the user clicks the toggle-all checkbox
    Then "Taste JavaScript" is marked as completed
    And "Buy a unicorn" is marked as completed
    And the toggle-all checkbox is checked

  Scenario: Mark all todos as active
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | true      |
      | Buy a unicorn    | true      |
    When the user clicks the toggle-all checkbox
    Then "Taste JavaScript" is not marked as completed
    And "Buy a unicorn" is not marked as completed
    And the toggle-all checkbox is not checked

  Scenario: Toggle-all becomes checked when every item is completed
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | true      |
      | Buy a unicorn    | false     |
    When the user marks "Buy a unicorn" as complete
    Then the toggle-all checkbox is checked

  Scenario: Toggle-all becomes unchecked when an item is uncompleted
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | true      |
      | Buy a unicorn    | true      |
    When the user marks "Buy a unicorn" as active
    Then the toggle-all checkbox is not checked

  Scenario: Toggle-all clears after clear completed
    Given the todo application is loaded
    And the todo list has the following items:
      | title           | completed |
      | Taste JavaScript | true      |
      | Buy a unicorn    | true      |
    When the user clicks "Clear completed"
    Then the toggle-all checkbox is not checked