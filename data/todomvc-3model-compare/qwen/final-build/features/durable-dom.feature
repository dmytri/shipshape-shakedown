Feature: Durable DOM
  As a real browser user
  I want DOM elements to stay stable when I interact with the app
  So that the UI doesn't flicker and my context is preserved

  Scenario: Toggling a checkbox preserves the same li element
    Given the page is loaded with a todo "Buy milk" that is not completed
    And I remember the li element for the todo "Buy milk"
    When I click the checkbox for the todo "Buy milk"
    Then the remembered li element is still in the DOM

  Scenario: Mark all preserves the same li elements
    Given the page is loaded with the todos "Buy milk" and "Walk the dog" both not completed
    And I remember the li elements for todos "Buy milk" and "Walk the dog"
    When I click the toggle all checkbox
    Then the remembered li elements are still in the DOM

  Scenario: Editing hides the checkbox and delete button via CSS
    Given the page is loaded with a todo "Buy milk" that is not completed
    When I double-click the label for the todo "Buy milk"
    Then the view area for the todo "Buy milk" is hidden by CSS
