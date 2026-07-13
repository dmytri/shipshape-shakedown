Feature: Tide observation settling

  Scenario: Prediction is stable after observations settle
    Given the tide table for Fundy Cove
    When the tide gauges settle
    And I ask for the next high tide after "2026-07-12T05:00:00Z"
    Then the predicted high tide is at "2026-07-12T16:45:00Z" with height 4.5
