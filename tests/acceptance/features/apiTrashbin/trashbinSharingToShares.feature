@api @files_trashbin-app-required @files_sharing-app-required
Feature: using trashbin together with sharing

  Background:
    Given the administrator has enabled DAV tech_preview
    And the administrator has set the default folder for received shares to "Shares"
    And auto-accept shares has been disabled
    And user "Alice" has been created with default attributes and without skeleton files
    And user "Alice" has uploaded file with content "file to delete" to "/textfile0.txt"

  @smokeTest
  Scenario Outline: deleting a received folder doesn't move it to trashbin
    Given using <dav-path> DAV path
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/shared"
    And user "Alice" has moved file "/textfile0.txt" to "/shared/shared_file.txt"
    And user "Alice" has shared folder "/shared" with user "Brian"
    And user "Brian" has accepted share "/shared" offered by user "Alice"
    And user "Brian" has moved folder "/Shares/shared" to "/Shares/renamed_shared"
    When user "Brian" deletes folder "/Shares/renamed_shared" using the WebDAV API
    Then as "Brian" the folder with original path "/Shares/renamed_shared" should not exist in the trashbin
    Examples:
      | dav-path |
      | old      |
      | new      |


  Scenario Outline: deleting a file in a received folder moves it to trashbin
    Given using <dav-path> DAV path
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/shared"
    And user "Alice" has moved file "/textfile0.txt" to "/shared/shared_file.txt"
    And user "Alice" has shared folder "/shared" with user "Brian"
    And user "Brian" has accepted share "/shared" offered by user "Alice"
    And user "Brian" has moved file "/Shares/shared" to "/Shares/renamed_shared"
    When user "Brian" deletes file "/Shares/renamed_shared/shared_file.txt" using the WebDAV API
    Then as "Brian" the file with original path "/Shares/renamed_shared/shared_file.txt" should exist in the trashbin
    Examples:
      | dav-path |
      | old      |
      | new      |


  Scenario Outline: deleting a file in a received folder when restored it comes back to the original path
    Given using <dav-path> DAV path
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/shared"
    And user "Alice" has moved file "/textfile0.txt" to "/shared/shared_file.txt"
    And user "Alice" has shared folder "/shared" with user "Brian"
    And user "Brian" has accepted share "/shared" offered by user "Alice"
    And user "Brian" has moved folder "/Shares/shared" to "/Shares/renamed_shared"
    And user "Brian" has deleted file "/Shares/renamed_shared/shared_file.txt"
    When user "Brian" restores the file with original path "/Shares/renamed_shared/shared_file.txt" using the trashbin API
    Then the HTTP status code should be "201"
    And the following headers should match these regular expressions for user "Brian"
      | ETag | /^"[a-f0-9:\.]{1,32}"$/ |
    And as "Brian" the file with original path "/Shares/renamed_shared/shared_file.txt" should not exist in the trashbin
    And user "Brian" should see the following elements
      | /Shares/renamed_shared/                |
      | /Shares/renamed_shared/shared_file.txt |
    And the content of file "/Shares/renamed_shared/shared_file.txt" for user "Brian" should be "file to delete"
    Examples:
      | dav-path |
      | old      |
      | new      |

  @skipOnOcV10 @issue-35900
  Scenario Outline: restoring a file to a read-only folder
    Given using <dav-path> DAV path
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Brian" has created folder "shareFolderParent"
    And user "Brian" has shared folder "shareFolderParent" with user "Alice" with permissions "read"
    And user "Alice" has accepted share "/shareFolderParent" offered by user "Brian"
    And as "Alice" folder "/Shares/shareFolderParent" should exist
    And user "Alice" has deleted file "/textfile0.txt"
    When user "Alice" restores the file with original path "/textfile0.txt" to "/Shares/shareFolderParent/textfile0.txt" using the trashbin API
    Then the HTTP status code should be "403"
    And as "Alice" the file with original path "/textfile0.txt" should exist in the trashbin
    And as "Alice" file "/Shares/shareFolderParent/textfile0.txt" should not exist
    And as "Brian" file "/shareFolderParent/textfile0.txt" should not exist
    Examples:
      | dav-path |
      | old      |
      | new      |

  @skipOnOcV10 @issue-35900
  Scenario Outline: restoring a file to a read-only sub-folder
    Given using <dav-path> DAV path
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Brian" has created folder "shareFolderParent"
    And user "Brian" has created folder "shareFolderParent/shareFolderChild"
    And user "Brian" has shared folder "shareFolderParent" with user "Alice" with permissions "read"
    And user "Alice" has accepted share "/shareFolderParent" offered by user "Brian"
    And as "Alice" folder "/Shares/shareFolderParent/shareFolderChild" should exist
    And user "Alice" has deleted file "/textfile0.txt"
    When user "Alice" restores the file with original path "/textfile0.txt" to "/Shares/shareFolderParent/shareFolderChild/textfile0.txt" using the trashbin API
    Then the HTTP status code should be "403"
    And as "Alice" the file with original path "/textfile0.txt" should exist in the trashbin
    And as "Alice" file "/Shares/shareFolderParent/shareFolderChild/textfile0.txt" should not exist
    And as "Brian" file "/shareFolderParent/shareFolderChild/textfile0.txt" should not exist
    Examples:
      | dav-path |
      | old      |
      | new      |
