Feature: Complete todo
  As someone with things to do
  I want to mark todos as complete or incomplete
  So that I can track my progress

  Scenario: Mark a todo complete
    Given the page is loaded with a todo "Buy milk" that is not completed
    When I click the checkbox for the todo "Buy milk"
    Then the todo "Buy milk" has the class "completed"
    And the checkbox for the todo "Buy milk" is checked

  Scenario: Mark a completed todo as active
    Given the page is loaded with a todo "Buy milk" that is completed
    When I click the checkbox for the todo "Buy milk"
    Then the todo "Buy milk" does not have the class "completed"
    And the checkbox for the todo "Buy milk" is not checked

  Scenario: Mark all as complete
    Given the page is loaded with the todos "Buy milk" and "Walk the dog" both not completed
    When I click the toggle all checkbox
    Then the todo "Buy milk" has the class "completed"
    And the todo "Walk the dog" has the class "completed"

  Scenario: Mark all checkbox reflects individual state
    Given the page is loaded with the todos "Buy milk" and "Walk the dog" both completed and the toggle all checkbox checked
    When I click the checkbox for the todo "Buy milk" to make it not completed
    Then the toggle all checkbox is not checked
