Feature: Routing
  As a user
  I want to filter todos by status
  So that I can focus on active or completed tasks

  Scenario: Default route shows all todos
    Given the app has active todos "Buy groceries" and "Walk the dog"
    And the app has completed todo "Do laundry"
    When the route is "#/"
    Then all todos should be visible
    And the "All" filter should be selected

  Scenario: Active route shows only active todos
    Given the app has active todos "Buy groceries" and "Walk the dog"
    And the app has completed todo "Do laundry"
    When the route is "#/active"
    Then only active todos should be visible
    And the "Active" filter should be selected

  Scenario: Completed route shows only completed todos
    Given the app has active todos "Buy groceries" and "Walk the dog"
    And the app has completed todo "Do laundry"
    When the route is "#/completed"
    Then only completed todos should be visible
    And the "Completed" filter should be selected

  Scenario: Checking a todo in active filter hides it
    Given the app has active todos "Buy groceries" and "Walk the dog"
    And the route is "#/active"
    When I click the checkbox on "Buy groceries"
    Then "Buy groceries" should be hidden from the list

  Scenario: Unchecking a todo in completed filter hides it
    Given the app has completed todos "Buy groceries" and "Walk the dog"
    And the route is "#/completed"
    When I click the checkbox on "Buy groceries"
    Then "Buy groceries" should be hidden from the list

  Scenario: Active filter persists on reload
    Given the route is "#/active"
    When the page is reloaded
    Then the route should remain "#/active"
    And only active todos should be visible