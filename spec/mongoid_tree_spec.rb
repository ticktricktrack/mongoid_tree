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

      it "the child should be at position 1" do
        @parent.children.first.position.should eq(1)
      end

    end

    context "a node with 2 children" do

      def reload
        @parent.reload
        @child_1.reload
        @child_2.reload
        @new_child.reload
      end

      before do
        @parent = Node.new(:name => "Parent")
        @child_1 = Node.new(:name => "Child_1")
        @child_2 = Node.new(:name => "Child_2")
        @new_child = Node.new(:name => "new_child")
        @parent.children << @child_1
        @parent.children << @child_2
        @child_1.position.should eq(1)
        @child_2.position.should eq(2)
        @parent.save
      end

      it "should add a child before child 1" do
        @child_1.insert_before(@new_child)
        reload
        @parent.children.sort.should eq([@new_child, @child_1, @child_2])
      end

      it "should add a child after child 1" do
        @child_1.insert_after(@new_child)
        reload
        @parent.children.sort.should eq([@child_1, @new_child, @child_2])
      end

      it "should add a child before child 2" do
        @child_2.insert_before(@new_child)
        reload
        @parent.children.sort.should eq([@child_1, @new_child, @child_2])
      end

      it "should add a child after child 2" do
        @child_2.insert_after(@new_child)
        reload
        @parent.children.sort.should eq([@child_1, @child_2, @new_child])
      end

      it "should append a child to children" do
        @parent.reload
        @parent.children << @new_child
        @parent.children.count.should eq(3)
        @parent.save
        @new_child.save
        reload                
        @parent.children.sort.should eq([@child_1, @child_2, @new_child])
      end

    end

    context "with full paths" do

      def getNode(number)
        Node.where(:name  => "Node_#{number}").first
      end

      before do
        # Build a tree
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

      # This is not BDD, I know...
      it "should store the path correctly" do
        getNode(6).parent_ids.should eql([getNode(1).id, getNode(2).id])
        getNode(2).parent_ids.should eql([getNode(1).id])
        getNode(3).parent_ids.should eql([getNode(1).id, getNode(2).id])
        getNode(4).parent_ids.should eql([getNode(1).id, getNode(2).id, getNode(3).id])
        getNode(5).parent_ids.should eql([getNode(1).id, getNode(2).id, getNode(3).id])
        getNode(10).parent_ids.should eql([getNode(1).id, getNode(8).id, getNode(9).id])
      end

    end

  end
end
