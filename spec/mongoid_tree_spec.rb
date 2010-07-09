require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoidTree" do

    before do
        [ Node ].each { |klass| klass.collection.remove }
    end

    context "with a root node" do
        before do
            @root = Node.new(:name => "Root")
        end

        context "without children" do
            it "should have a name" do
                @root.name.should eq("Root") 
            end

            it "should have no children" do
                @root.children.count.should be(0)
            end

        end

        context "adding a child" do

            before do
                @child_1 = Node.new(:name => "Child 1")
                @root.children << @child_1
                @root.save
                @child_1.save
            end

            it "should add a child" do
                @root.children.count.should eq(1)
            end  
        end

    end

end
