@wip
Feature: Create workspace
  To store my notes
  As a user
  I need to create a workspace

  Scenario: Create workspace

    Given I am logged in
    And have opened the home page
    Then the "create workspace form" should be displayed

    When I enter "My workspace" in "workspace name"
    And click the "create workspace button"

    Then I should be on the workspace page for "My workspace"
