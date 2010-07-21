require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

context "module tests" do
  before do
    @node_1 = Factory.create(:node)
    @node_2 = Factory.create(:node)
    @node_1.children << @node_2
    @node_1.save!
  end
  
  it "should have a parent" do
    @node_2.parent.first.should eq(@node_1)
  end
end