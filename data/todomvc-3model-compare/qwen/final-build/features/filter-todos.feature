Feature: Filter todos
  As someone with things to do
  I want to filter my todos by status
  So that I can focus on what matters

  Scenario: Show all todos by default
    Given the page is loaded with a completed todo "Buy milk" and an active todo "Walk the dog"
    Then the todo list shows both "Buy milk" and "Walk the dog"
    And the "All" filter link has the class "selected"

  Scenario: Filter to active todos
    Given the page is loaded with a completed todo "Buy milk" and an active todo "Walk the dog"
    When I navigate to the active filter
    Then the todo list shows only "Walk the dog"
    And the "Active" filter link has the class "selected"

  Scenario: Filter to completed todos
    Given the page is loaded with a completed todo "Buy milk" and an active todo "Walk the dog"
    When I navigate to the completed filter
    Then the todo list shows only "Buy milk"
    And the "Completed" filter link has the class "selected"

  Scenario: Filter persists on reload
    Given the page is loaded with a completed todo "Buy milk" and an active todo "Walk the dog"
    When I navigate to the active filter
    And I reload the page
    Then the todo list shows only "Walk the dog"
    And the "Active" filter link has the class "selected"
