Feature: Tide station

  Scenario: A tide station is provisioned for the cove
    Given the tide table for Fundy Cove
    When a tide station is provisioned for the cove
    Then the station is named "Fundy Cove"

  Scenario: A provisioned station reports the next high tide
    Given a provisioned tide station for Fundy Cove
    When the station reports the next high tide after "2026-07-12T05:00:00Z"
    Then the station report shows "2026-07-12T16:45:00Z"

  Scenario: A provisioned station raises a low-water alert
    Given a provisioned tide station for Fundy Cove
    When the station checks low water below 0.75
    Then the alert names the tide at "2026-07-12T22:55:00Z"

  Scenario: The dashboard requests the station from its provider
    Given a dashboard station provider
    When the dashboard opens
    Then the provider was called once
    And the dashboard title is "Tides at Fundy Cove"
