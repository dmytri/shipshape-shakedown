Feature: Application page
  As a user opening the app in a web browser
  I want a real index.html that loads the application
  So that I can use the todo app directly in my browser

  Rule: The project root must contain a real index.html built from the template

  Scenario: index.html exists at the project root
    Given the project root directory
    Then a file named "index.html" exists

  Scenario: index.html loads the app JavaScript
    Given the file "index.html" exists at the project root
    Then the file contains a script element whose src attribute is "js/app.js"

  Rule: The index.html must contain the todo app markup structure from the template

  Scenario: index.html contains the header with the new-todo input
    Given the file "index.html" exists at the project root
    Then the file contains a "header" element with class "header"
    And the "header" element contains an input with class "new-todo" and placeholder "What needs to be done?"

  Scenario: index.html contains the main section with the todo list
    Given the file "index.html" exists at the project root
    Then the file contains a section element with class "main"
    And the "main" section contains a checkbox with class "toggle-all"
    And the "main" section contains a list element with class "todo-list"

  Scenario: index.html contains the footer with filters and controls
    Given the file "index.html" exists at the project root
    Then the file contains a footer element with class "footer"
    And the "footer" section contains a span with class "todo-count"
    And the "footer" section contains filter links for "All", "Active", and "Completed"
    And the "footer" section contains a button with class "clear-completed"

  Rule: The app renders and is interactive when the page loads in a browser

  Scenario: Opening index.html in a browser renders the working todo app
    Given the file "index.html" exists at the project root
    And the file "js/app.js" exists at the project root
    When the index.html is loaded in a browser
    Then the page displays the todo app header with the title "todos"
    And the new-todo input is focused and ready for input
    And the main section and footer are hidden because there are no todos yet