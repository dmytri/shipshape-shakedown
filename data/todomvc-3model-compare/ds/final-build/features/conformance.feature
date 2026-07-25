@conformance
Feature: Editing conformance
  As a developer
  I want the edit-commit-on-Enter to release focus instead of committing directly
  So that a real browser does not double-commit via the subsequent blur event

  Rule: Enter handler delegates to blur

  Scenario: Enter keydown handler calls editInput.blur() and does not call saveEdit directly
    Given the file "js/app.js" exists
    When I read the file "js/app.js"
    Then the source should contain "editInput.blur();" inside the ENTER_KEY handler
    And the source should not contain "saveEdit(id, editInput.value);" inside the ENTER_KEY handler in attachEditHandlers