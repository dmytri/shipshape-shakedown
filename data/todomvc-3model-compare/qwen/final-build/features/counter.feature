Feature: Todo counter
  As someone with things to do
  I want to see how many active todos remain
  So that I know how much is left to do

  Scenario: Display active count with correct pluralization
    Given the page is loaded with two active todos and one completed todo
    Then the counter displays "2 items left"

  Scenario: Display singular for one active todo
    Given the page is loaded with one active todo and no completed todos
    Then the counter displays "1 item left"

  Scenario: Counter updates when a todo is completed
    Given the page is loaded with two active todos
    When I complete one of the active todos
    Then the counter displays "1 item left"
