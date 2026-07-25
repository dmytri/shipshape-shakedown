Feature: Page render
  As a user opening the app in a browser
  I want to see the todo application
  So that I can use the app to manage my tasks

  Scenario: The servable page contains the app structure and loads the application script
    Given the index.html file exists at the project root
    When the page is examined
    Then the page contains the new-todo input with placeholder "What needs to be done?"
    And the page contains the todo-list section
    And the page contains the footer with the item counter and filter links
    And the page includes a script tag loading js/app.js
