Feature: Create repositories from files
    In order provide packages to end users,
    As an operator
    I want to create multiple repositories from a set of files

Scenario: Create a repository for source packages in a flat directory
    Given an empty file named "srcpkgs/foo-1.0.0.i686.rpm"
    And an empty file named "srcpkgs/foo-1.0.0.i386.deb"
    And an empty file named "srcpkgs/ubuntu/foo-1.0.0-bar.i386.deb"
    When I successfully run `melai -r repo create -p srcpkgs`
    Then a directory named "repo/redhat/1.0/i686/RPMS" should exist
    And a directory named "repo/redhat/os/i686/RPMS" should exist
    And a directory named "repo/debian-sysvinit/dists/dist/10gen/binary-i386" should exist
    And a directory named "repo/ubuntu-upstart/dists/dist/10gen/binary-i386" should exist

Scenario Outline: Create a repository directory structure for a given file
    Given a directory named "repo" does not exist
    And an empty file named <SrcFile>
    When I successfully run `melai -r repo create -p srcpkgs`
    Then a directory named <RepoDir> should exist
    Examples:
        | SrcFile                                                             | RepoDir                                              |
        | "srcpkgs/redhat/foo-2.0.0.i686.rpm"                                 | "repo/redhat/os/i686/RPMS"                           |
        | "srcpkgs/redhat/foo-2.0.1.i686.rpm"                                 | "repo/redhat/2.0/i686/RPMS"                          |
        | "srcpkgs/redhat/foo-2.0.2.x86_64.rpm"                               | "repo/redhat/2.0/x86_64/RPMS"                        |
        | "srcpkgs/debian/foo-2.0.0.i386.deb"                                 | "repo/debian-sysvinit/dists/dist/10gen/binary-i386/" |
        | "srcpkgs/redhat/os/i686/RPMS/bar-server-2.0.6-version_1.i686.rpm"   | "repo/redhat/os/i686/RPMS/"                          |
        | "srcpkgs/redhat/os/i686/RPMS/bar-unstable-2.1.0-version_1.i686.rpm" | "repo/redhat/2.1/i686/RPMS/"                         |
        | "srcpkgs/redhat/os/i686/RPMS/bar18-server-1.8.5-version_1.i686.rpm" | "repo/redhat/1.8/i686/RPMS/"                         |
        | "srcpkgs/redhat/os/i686/RPMS/bar-2.0.6-version_1.i686.rpm"          | "repo/redhat/2.0/i686/RPMS/"                         |

