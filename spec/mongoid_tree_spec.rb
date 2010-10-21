require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Mongoid::Acts::Tree do

  before do
    [ Node ].each { |klass| klass.collection.remove }
  end
  
  shared_examples_for "a root node" do
    its (:parent_ids) {should be_empty}
    its (:parent) {should be_nil}
    its (:root) {should be_nil}
    it {should be_root}
    its (:ancestors) {should be_empty}
    specify{subject.ancestors_and_self.should eq([subject])}
  end
  
  shared_examples_for "a parent node" do
    its (:child_ids) {should_not be_empty}
    its (:children) {should_not eq([])}
    specify{subject.depth_first.should_not eq([subject])}
    specify{subject.breadth_first.should_not eq([subject])}
  end
  
  shared_examples_for "a child node" do
    its (:parent_ids) {should_not be_empty}
    its (:parent) {should eq(parent)}
    its (:root) {should_not be_nil}
    it {should_not be_root}
    its (:ancestors) {should_not be_empty}
    specify{subject.ancestors_and_self.should_not eq([subject])}
  end
  
  shared_examples_for "a leaf node" do
    its (:child_ids) {should be_empty}
    its (:children) {should eq([])}
    specify{subject.depth_first.should eq([subject])}
    specify{subject.breadth_first.should eq([subject])}
    it { should be_a_leaf }
    
  end
  
  describe "A node" do
    let(:node) { Node.create :name => "A Node" }
    subject {node}
    
    it { should be_valid }
    it_should_behave_like "a leaf node"
    it_should_behave_like "a root node"
    
    context "when adding a child" do
      let(:parent){node}
      let(:child){Node.create(:name => "A Child")}          
      before do
        node.children << child
      end
      
      it_should_behave_like "a parent node"
      it_should_behave_like "a root node"
      
      it "should change the children count" do
        expect{
          node.children << Node.create(:name => "another child")
        }.to change{node.child_ids.count}.by(1)
      end
      
      it "should exist 2 nodes" do
        Node.count.should be(2)
      end
      
      it "should have 1 child" do
        node.children.count.should be(1)
      end
      
      it "should be able to access the child" do
        node.children.first.should eq(child)
      end
      
      its (:depth_first) {should eq([parent, child])}
      its (:breadth_first) {should eq([parent,child])}
      
      context "the child" do
        subject{child}
        it_should_behave_like "a leaf node"
        it_should_behave_like "a child node"
      end
      
    end
    
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
      
      context "on the parent" do
        it "should not be a leaf node" do
          @parent.leaf?.should be(false)
        end
        
        it "should have depth 0" do
          @parent.depth.should be(0)
        end
        
        it "should be root" do
          @parent.root?.should be(true)
        end
      end
      
      context "on the child" do
        it "should be a leaf node" do
          @child.leaf?.should be(true)
        end
        
        it "should have depth 1" do
          @child.depth.should be(1)
        end
        
        it "should return the parent as root" do
          @child.root.should eq(@parent)
        end
        
        it "should not be root" do
          @child.root?.should be(false)
        end
        
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
      
      context "Moving a subtree" do
        it "should rebuild the paths" do
          getNode(9).move_to(getNode(6))
          getNode(2).child_ids.should eql([getNode(3).id, getNode(6).id])
          getNode(8).child_ids.should eql([getNode(12).id])
          
          
          getNode(9).parent_ids.should eql([getNode(1).id, getNode(2).id, getNode(6).id])
          getNode(10).parent_ids.should eql([getNode(1).id, getNode(2).id, getNode(6).id, getNode(9).id])
          getNode(11).parent_ids.should eql([getNode(1).id, getNode(2).id, getNode(6).id, getNode(9).id])
        end
      end

      it "should fix the position" do
        getNode(11).move_to(getNode(1))
        getNode(11).position.should be(4)
      end
      
      it "should move a node to a specific position" do
        getNode(11).move_to_position(getNode(1),2)
        getNode(2).position.should be(1)
        getNode(11).position.should be(2)
        getNode(7).position.should be(3)
        getNode(8).position.should be(4)
        
      end

    end

  end
end
