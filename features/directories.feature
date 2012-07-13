Feature: Set up the repository directory
    In order to increase the amount of confidence in repeatable package repositories,
    As an operator
    I want to set up all the directories I need

Scenario: Listing an empty source directory returns no files
    Given a directory named "emptysrcpkgs"
    When I successfully run `melai list -p emptysrcpkgs`
    Then the output should contain exactly ""

Scenario: List all package files in a source directory
    Given a directory named "srcpkgs"
    And an empty file named "srcpkgs/example-1.0.deb"
    And an empty file named "srcpkgs/example-1.0.rpm"
    When I successfully run `melai list -p srcpkgs`
    Then the output should contain:
        """
        srcpkgs/example-1.0.deb
        srcpkgs/example-1.0.rpm
        """

# Final step, cleans up
Scenario: A repository directory exists and I want to destroy it
    Given a directory named "repo"
    When I successfully run `melai -r repo destroy`
    Then a directory named "repo" should not exist
