Feature: Log out
  To prevent access to my data, or log in again
  As a user
  I need to be able to log out

  Scenario Outline: Log out

    Given I am logged in
    And have opened <from page>
    When I click the "log out button"
    Then I should be on the home page
    And I should not be logged in

    Examples:
      | from page     |
      | the home page |
      | a workspace   |
