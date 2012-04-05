Feature: Login
  In order to use the notes app
  As a user
  I need to be able to log in

  Scenario: Login form displays
    When I open the home page
    Then the "login form" should be displayed
    And it should have the following fields:
      | name       | value                                 |
      | openid_url | https://www.google.com/accounts/o8/id |
