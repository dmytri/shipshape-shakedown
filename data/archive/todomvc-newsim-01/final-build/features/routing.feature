Feature: Routing
  As a user
  I want to filter the todo list by completion state
  So that I can focus on active or completed tasks

  Rule: The default route shows all todos

  Scenario: Default route shows all todos
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| false     |
      | Walk the dog | true      |
    When the app is at the default route "#/"
    Then the todo list shows items with titles "Buy groceries" and "Walk the dog"

  Rule: The active route filters to incomplete todos

  Scenario: Active route shows only incomplete todos
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| false     |
      | Walk the dog | true      |
    When the user navigates to the "#/active" route
    Then the todo list shows only items with titles "Buy groceries"

  Rule: The completed route filters to complete todos

  Scenario: Completed route shows only complete todos
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| false     |
      | Walk the dog | true      |
    When the user navigates to the "#/completed" route
    Then the todo list shows only items with titles "Walk the dog"

  Rule: The selected class is applied to the current filter link

  Scenario: The selected class toggles on filter links
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user navigates to the "#/active" route
    Then the filter link for "Active" has the "selected" class
    And the filter link for "All" does not have the "selected" class

  Rule: Items updated in a filtered view respond correctly

  Scenario: Completing an active todo hides it in the active filter
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| false     |
      | Walk the dog | true      |
    When the user navigates to the "#/active" route
    And the user clicks the toggle for the todo titled "Buy groceries"
    Then the todo list is empty

  Scenario: Uncompleting a completed todo hides it in the completed filter
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| false     |
      | Walk the dog | true      |
    When the user navigates to the "#/completed" route
    And the user clicks the toggle for the todo titled "Walk the dog"
    Then the todo list is empty

  Rule: The active filter persists across reload

  Scenario: Active filter is preserved on reload
    Given the app has loaded with todos:
      | title        | completed |
      | Buy groceries| false     |
      | Walk the dog | true      |
    When the user navigates to the "#/active" route
    And the app reloads
    Then the route is "#/active"
    And the todo list shows only items with titles "Buy groceries"