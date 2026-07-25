Feature: Edit todo
  As someone with things to do
  I want to edit the title of an existing todo
  So that I can correct or update task descriptions

  Scenario: Enter edit mode by double-clicking the label
    Given the page is loaded with a todo "Buy milk" that is not completed
    When I double-click the label for the todo "Buy milk"
    Then the todo "Buy milk" has the class "editing"
    And the edit input for the todo "Buy milk" is focused

  Scenario: Save edit on Enter
    Given the page is loaded with a todo "Buy milk" in edit mode
    When I change the edit input value to "Buy eggs" and press Enter
    Then the todo list contains a todo titled "Buy eggs"
    And the todo "Buy eggs" does not have the class "editing"

  Scenario: Save edit on blur
    Given the page is loaded with a todo "Buy milk" in edit mode
    When I change the edit input value to "Buy eggs" and move focus away
    Then the todo list contains a todo titled "Buy eggs"
    And the todo "Buy eggs" does not have the class "editing"

  Scenario: Discard edit on Escape
    Given the page is loaded with a todo "Buy milk" in edit mode
    When I change the edit input value to "Buy eggs" and press Escape
    Then the todo list contains a todo titled "Buy milk"
    And the todo "Buy milk" does not have the class "editing"

  Scenario: Empty edit destroys the todo
    Given the page is loaded with a todo "Buy milk" in edit mode
    When I change the edit input value to "" and press Enter
    Then the todo list does not contain a todo titled "Buy milk"
