Feature: You page feature
  Scenario: Visiting my page
    Given I am logged in as amyhref@gmail.com
    When I visit the homepage
    And I click on You
    Then I should be on my highlights page
    And I should see a Home link
    And I should see an All link
