Feature: Annual tide tables for every published station

  The service publishes a tide table for each station it covers. Each station has
  its own harmonic constants, so each table is computed for that station.

  Scenario: The 2026 tables cover every published station
    Given the tide service is published
    When I generate the annual tide tables for every station in 2026
    Then every published station has a table
    And each table alternates high and low water

  Scenario: The 2027 tables cover every published station
    Given the tide service is published
    When I generate the annual tide tables for every station in 2027
    Then every published station has a table
    And each table alternates high and low water

  Scenario: The 2028 tables cover every published station
    Given the tide service is published
    When I generate the annual tide tables for every station in 2028
    Then every published station has a table
    And each table alternates high and low water

  Scenario: Station tables are not copies of one another
    Given the tide service is published
    When I generate the annual tide tables for every station in 2029
    Then the stations do not share a single first high water
