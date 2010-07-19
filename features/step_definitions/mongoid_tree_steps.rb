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