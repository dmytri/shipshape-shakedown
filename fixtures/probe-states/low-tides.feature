Feature: Low tide prediction

  Scenario: Next low tide after a given time
    Given the tide table for Fundy Cove
    When I ask for the next low tide after "2026-07-12T05:00:00Z"
    Then the predicted low tide is at "2026-07-12T10:30:00Z"

  Scenario: No upcoming low tide is an error
    Given the tide table for Fundy Cove
    When I ask for the next low tide after "2026-07-13T00:00:00Z"
    Then the low tide prediction fails with "no upcoming low tide in data"

  Scenario: Low tide includes the height
    Given the tide table for Fundy Cove
    When I ask for the next low tide after "2026-07-12T05:00:00Z"
    Then the predicted low tide has height 0.8
