Feature: Tide prediction

  Scenario: Next high tide after a given time
    Given the tide table for Fundy Cove
    When I ask for the next high tide after "2026-07-12T05:00:00Z"
    Then the predicted high tide is at "2026-07-12T16:45:00Z" with height 4.5

  Scenario: No upcoming high tide is an error
    Given the tide table for Fundy Cove
    When I ask for the next high tide after "2026-07-13T00:00:00Z"
    Then the prediction fails with "no upcoming high tide in data"
