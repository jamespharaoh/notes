Feature: Login
  In order to use the notes app
  As a user
  I need to be able to log in

  Scenario: Need to log in

    When I open the home page

    Then I should not be logged in
    And the "login form" should be displayed

  Scenario: Successful login

    When I log in via openid

    Then I should be on the home page
    And I should be logged in
