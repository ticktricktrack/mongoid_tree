Given /^I have no nodes$/ do
  Node.delete_all
end

Given /^the following nodes exist:$/ do |nodes_table|
  # table is a Cucumber::Ast::Table
  nodes_table.hashes.each do |hash|
    node = Node.new(:name => hash[:name])
    if !(hash[:parent] == "")
      parent = Node.find(:first, :conditions => { :name => hash[:parent]})
      parent.children << node
      parent.save!
      node.save!
    else
      Node.create( :name => hash[:name])
    end
  end
end

Given /^I create a tree$/ do
    # There is probably a clever lambda way to do this
    node_1  = Factory.create(:node, :name => "Node_1")
    node_2  = Factory.create(:node, :name => "Node_2")
    node_3  = Factory.create(:node, :name => "Node_3")
    node_4  = Factory.create(:node, :name => "Node_4")
    node_5  = Factory.create(:node, :name => "Node_5")
    node_6  = Factory.create(:node, :name => "Node_6")
    node_7  = Factory.create(:node, :name => "Node_7")
    node_8  = Factory.create(:node, :name => "Node_8")
    node_9  = Factory.create(:node, :name => "Node_9")
    node_10 = Factory.create(:node, :name => "Node_10")
    node_11 = Factory.create(:node, :name => "Node_11")
    node_12 = Factory.create(:node, :name => "Node_12")
    
    node_1.children << node_7
    node_7.insert_before(node_2)
    node_7.insert_after(node_8)
    node_8.children << node_9
    node_8.children << node_12
    node_9.children << node_11
    node_11.insert_before(node_10)
    node_2.children << node_3
    node_3.insert_after(node_6)
    node_3.children << node_4
    node_4.insert_after(node_5)
    
    node_1.save!
end


When /^I request the children depth first$/ do
  @root = Node.find(:first, :conditions => { :name => "Node_1" })
  @root.should_not be(nil)
  @children = @root.depth_first.map{|node| [node.name]}
end

Then /^I should get the children in the following order$/ do |expected_children_order|
  # table is a Cucumber::Ast::Table
  expected_children_order.diff!(@children)
end

Then /^I should have (\d+) Nodes$/ do |count|
  Node.count.should be(count.to_i)
end
