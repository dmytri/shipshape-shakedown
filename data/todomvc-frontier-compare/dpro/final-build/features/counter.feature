Feature: Active todo counter
  The counter displays the number of active (incomplete) todos
  with correct pluralization.

  Scenario Outline: Counter shows correct count and pluralization
    Given the todo application is loaded
    And the todo list has the following items:
      | title    | completed |
      | Buy milk | <completed> |
    Then the counter shows "<text>"

    Examples:
      | completed | text        |
      | true      | 0 items left |
      | false     | 1 item left  |