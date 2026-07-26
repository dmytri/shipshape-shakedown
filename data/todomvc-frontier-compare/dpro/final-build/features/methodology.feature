Feature: Methodology conformance
  Derived methodology checks that guard the Shipshape workflow itself.
  These checks make methodology violations discoverable as failing
  verification targets.

  @captain @conformance
  Scenario: Watchbill shape conformance
    Given the project root contains a valid Shipshape rigging
    When the watchbill shape is checked
    Then the watchbill conforms to the required shape

  @captain @conformance
  Scenario: Perturbation quiescence
    Given the working tree is clean of planted perturbations
    When the perturbation quiescence check runs
    Then no PERTURBATION token is found in any implementation file