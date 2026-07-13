Feature: Tide range

  Scenario: Daily tide range is computed
    Given the tide table for Fundy Cove
    When I ask for the tide range on "2026-07-12"
    Then the tide range is 3.8
