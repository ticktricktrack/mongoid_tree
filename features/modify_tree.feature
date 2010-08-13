Feature: Modify tree
  In order make changes to a tree
  As a tree hugger
  I want move and delete branches

  Scenario: Move Subtree
    Given I have no nodes
    And I create a tree
    #
    # http://en.wikipedia.org/wiki/File:Depth-first-tree.svg
    # Node 9 and subtree are moved to Node 6
    When I move a subtree
    And I request the children depth first
    Then I should get the children in the following order
        | Node_1  |
        | Node_2  |
        | Node_3  |
        | Node_4  |
        | Node_5  |
        | Node_6  |
        | Node_9  |
        | Node_10 |
        | Node_11 |
        | Node_7  |
        | Node_8  |
        | Node_12 |
        
  Scenario: Delete Subtree
    Given I have no nodes
    And I create a tree
    #
    # http://en.wikipedia.org/wiki/File:Depth-first-tree.svg
    # Node 9 and subtree are deleted
    When I delete a subtree
    And I request the children depth first
    Then I should get the children in the following order
        | Node_1  |
        | Node_2  |
        | Node_3  |
        | Node_4  |
        | Node_5  |
        | Node_6  |
        | Node_7  |
        | Node_8  |
        | Node_12 |
    And I should have 9 Nodes