Feature: Servable Page
  As a browser user
  I want the application served from index.html
  So that the todo app renders and runs from the project root

  Rule: index.html at project root

  Scenario: index.html exists and includes the app shell and script source
    Given the project root contains "index.html"
    Then "index.html" contains a todo input element
    And "index.html" contains a main list section
    And "index.html" contains a footer with controls
    And "index.html" loads "js/app.js" via a script tag