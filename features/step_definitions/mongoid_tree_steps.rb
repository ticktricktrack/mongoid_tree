Given /^the following nodes exist:$/ do |nodes_table|
  # table is a Cucumber::Ast::Table
  nodes_table.hashes.each do |hash|
    node = Node.new(:name => hash[:name])
    if hash[:parent]
        parent = Node.find(:first, :conditions => { :name => hash[:parent]})
        parent.children << node
        parent.save
    end
  end
end

When /^I request the children depth first$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should get the children in the following order$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end
