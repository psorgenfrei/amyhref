Feature: Home page
  Scenario: Viewing the site homepage
  Given I am not signed in
  When I am on the homepage
  Then I should see "Sign in"
  And I should see some embedly cards
