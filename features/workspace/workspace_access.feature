Feature: Access workspace
  To access my notes
  As a user
  I need to find my workspace

  Scenario: Find workspace

    Given I am logged in
    And have created a workspace named "My workspace"

    When I open the home page

	Then I should see a link titled "My workspace"

	When I follow the link

	Then I should be on the workspace page for "My workspace"
