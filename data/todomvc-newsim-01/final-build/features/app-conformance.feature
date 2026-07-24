Feature: App source conformance
  As a project maintainer
  I want the app source to satisfy structural rules
  So that the project's own method is enforced

  Rule: The edit-commit re-entrancy guard prevents the double-commit bug

  @conformance
  Scenario: The edit field's Enter handler delegates to blur, not to commitEdit directly
    Given the app source at "js/app.js"
    When a conformance check inspects the edit-field Enter handler
    Then the Enter handler calls editInput.blur()
    And the Enter handler does not call commitEdit directly