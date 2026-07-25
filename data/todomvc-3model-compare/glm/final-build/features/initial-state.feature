Feature: Initial State
  As a user loading the app
  I want the app to start in a clean state
  So that I can begin managing todos immediately

  Scenario: New todo input has autofocus on page load
    When the page loads
    Then the new todo input should be focused

  Scenario: App loads with empty state when no localStorage data
    Given localStorage has no todo data
    When the page loads
    Then the todo list should be empty
    And the main section should be hidden
    And the footer should be hidden