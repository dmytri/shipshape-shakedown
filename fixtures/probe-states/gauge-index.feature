Feature: Gauge index lookups

  The gauge reports observations by station pass. Lookups answer from the tide
  table regardless of the order the gauge reported it in.

  Scenario: The next high tide after a given time
    Given the tide table for Fundy Cove is loaded
    When I look up the next high tide after "2026-07-12T05:00:00Z"
    Then the lookup reports "2026-07-12T16:45:00Z"
