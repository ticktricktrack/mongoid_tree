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
    12.times{ |i| Factory.create(:node, :name => "Node_#{i+1}") }

    Node.where(:name  => "Node_1").first.children << Node.where(:name => "Node_7").first
    Node.where(:name  => "Node_7").first.insert_before(Node.where(:name => "Node_2").first)
    Node.where(:name  => "Node_1").first.children << Node.where(:name => "Node_8").first
    Node.where(:name  => "Node_2").first.children << Node.where(:name => "Node_3").first
    Node.where(:name  => "Node_3").first.insert_after(Node.where(:name => "Node_6").first)
    Node.where(:name  => "Node_8").first.children << Node.where(:name => "Node_9").first
    Node.where(:name  => "Node_9").first.children << Node.where(:name => "Node_11").first
    Node.where(:name  => "Node_3").first.children << Node.where(:name => "Node_5").first
    Node.where(:name  => "Node_9").first.insert_after(Node.where(:name => "Node_12").first)
    Node.where(:name  => "Node_5").first.insert_before(Node.where(:name => "Node_4").first)
    Node.where(:name  => "Node_11").first.insert_before(Node.where(:name => "Node_10").first)
end


When /^I request the children depth first$/ do
    @root = Node.find(:first, :conditions => { :name => "Node_1" })
    @root.should_not be(nil)
    @children = @root.depth_first.map{|node| [node.name]}
    puts @children.inspect
end

When /^I request the children breadth first$/ do
    @root = Node.find(:first, :conditions => { :name => "Node_1" })
    @root.should_not be(nil)
    @children = @root.breadth_first.map{|node| [node.name]}
end

When /^I move a subtree$/ do
    Node.first(:conditions => {:name => "Node_9"}).move_to(Node.first(:conditions => {:name => "Node_6"}))
end

Then /^I should get the children in the following order$/ do |expected_children_order|
    # table is a Cucumber::Ast::Table
    expected_children_order.diff!(@children)
end

Then /^I should have (\d+) Nodes$/ do |count|
    Node.count.should be(count.to_i)
end
