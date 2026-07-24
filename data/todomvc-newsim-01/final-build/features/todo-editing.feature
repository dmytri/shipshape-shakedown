Feature: Todo editing
  As a user
  I want to edit a todo title
  So that I can correct or change my tasks

  Rule: Editing is activated by double-clicking the label

  Scenario: Double-clicking a todo label activates editing mode
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user double-clicks the todo titled "Buy groceries"
    Then the todo item "Buy groceries" has the "editing" class

  Rule: Editing ends and saves on pressing Enter

  Scenario: Pressing Enter saves the edited title
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user double-clicks the todo titled "Buy groceries"
    And the user changes the title to "Buy organic groceries" and presses Enter
    Then the todo list contains an item with title "Buy organic groceries"
    And the todo item "Buy organic groceries" does not have the "editing" class

  Scenario: Pressing Enter while editing releases focus from the edit field
    Given a todo "write tests" that is in edit mode
    When the user presses Enter in its edit field
    Then that edit field is no longer the focused element

  Scenario: Editing a todo and pressing Enter saves the new trimmed title
    Given a todo "write tests" that is in edit mode
    When the user replaces the text with "  ship it  " and presses Enter
    Then the todo's title is "ship it"
    And there is exactly one todo

  Scenario: Clearing a todo's text and committing deletes it
    Given a todo "write tests" that is in edit mode
    When the user clears the edit field and presses Enter
    Then there are no todos

  Rule: Editing ends and saves on blur

  Scenario: Blurring the edit input saves the title
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user double-clicks the todo titled "Buy groceries"
    And the user changes the title to "Buy organic groceries" and blurs the input
    Then the todo list contains an item with title "Buy organic groceries"
    And the todo item "Buy organic groceries" does not have the "editing" class

  Rule: An empty trimmed input destroys the todo

  Scenario: Clearing the title and pressing Enter destroys the todo
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user double-clicks the todo titled "Buy groceries"
    And the user clears the title and presses Enter
    Then the todo list contains no items

  Scenario: Clearing the title and blurring destroys the todo
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user double-clicks the todo titled "Buy groceries"
    And the user clears the title and blurs the input
    Then the todo list contains no items

  Rule: Pressing Escape cancels editing and discards changes

  Scenario: Pressing Escape discards the edit and restores the original title
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user double-clicks the todo titled "Buy groceries"
    And the user changes the title to "Buy organic groceries" and presses Escape
    Then the todo list contains an item with title "Buy groceries"
    And the todo item "Buy groceries" does not have the "editing" class

  Rule: Editing mode hides other controls

  Scenario: Editing mode hides the checkbox, label and destroy button
    Given the app has loaded with todos:
      | title        |
      | Buy groceries|
    When the user double-clicks the todo titled "Buy groceries"
    Then the checkbox for the todo titled "Buy groceries" is not visible
    And the label for the todo titled "Buy groceries" is not visible
    And the destroy button for the todo titled "Buy groceries" is not visible

  Rule: Order is preserved when editing a todo

  Scenario: Editing a todo keeps it in its original position
    Given the todos "one", "two", "three" exist
    When the user edits the second todo to "two edited"
    Then the todos are, in order, "one", "two edited", "three"