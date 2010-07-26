require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoidTree" do

    before do
        [ Node ].each { |klass| klass.collection.remove }
    end

    describe "A tree of nodes" do

        context "A node with a child" do
            
            before do
                @parent = Node.new(:name => "Parent")
                @child = Node.new(:name => "Child")
                @parent.children << @child
                @parent.save
            end
            
            it "should have 1 child" do
                @parent.children.count.should be(1)
                @parent.children.first.should eq(@child)
            end        

            it "a child should know it's parent" do
                @child.parent.should eq(@parent)
            end
        end

        context "a node with 2 children" do
            before do
                @parent = Node.new(:name => "Parent")
                @child_1 = Node.new(:name => "Child_1")
                @child_2 = Node.new(:name => "Child_2")
                @child_3 = Node.new(:name => "Child_3")
                @parent.children << @child_1
                @parent.children << @child_2
                @parent.save
            end
            
            it "should add a child before child 1" do
                @child_1.insert_before(@child_3)
                @parent.children.sort.to_a.shift.should eq(@child_3)
                @parent.children.sort.to_a.shift.should eq(@child_1)
                @parent.children.sort.to_a.shift.should eq(@child_2)
            end

            it "should add a child after child 1" do
                @child_1.insert_after(@child_3)
                @parent.children.sort.to_a.shift.should eq(@child_1)
                @parent.children.sort.to_a.shift.should eq(@child_3)
                @parent.children.sort.to_a.shift.should eq(@child_2)
            end

            it "should add a child before child 2" do
                @child_2.insert_before(@child_3)
                @parent.children.sort.to_a.shift.should eq(@child_1)
                @parent.children.sort.to_a.shift.should eq(@child_3)
                @parent.children.sort.to_a.shift.should eq(@child_2)
            end

            it "should add a child after child 2" do
                @child_2.insert_before(@child_3)
                @parent.children.sort.to_a.shift.should eq(@child_1)
                @parent.children.sort.to_a.shift.should eq(@child_2)
                @parent.children.sort.to_a.shift.should eq(@child_3)
            end

            it "should append a child to children" do
                @parent.children << @child_3
                @parent.children.sort.to_a.shift.should eq(@child_1)
                @parent.children.sort.to_a.shift.should eq(@child_2)
                @parent.children.sort.to_a.shift.should eq(@child_3)
            end
            
        end

    end
end
