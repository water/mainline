Feature: Labs
  Scenario: List labs
    Given I am logged in as a student
    And I am a member of a lab group which has 3 labs
    When I visit the labs page
    Then I should see 3 labs