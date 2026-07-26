Feature: New todo input focus
  The new todo input receives focus on page load. The current
  implementation relies on the HTML autofocus attribute with
  no explicit JavaScript seam.

  @shipwright
  Scenario: New todo input focus is an explicit JavaScript seam
    Given the todo application is loaded
    Then the new todo input is focused