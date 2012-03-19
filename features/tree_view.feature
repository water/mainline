Feature: Tree-view
  In order to upload files to specific directories,
  A student
  Should be able to browse a git tree
  
  Scenario: The student should see a tree
    Given that the user is logged in
      And that the user is a student
      And that the user is registered for a course
      And that the user has joined a lab group
    When the user goes to the upload screen
    Then the user should see a tree view 
  