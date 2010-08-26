require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoidTree" do
  context "on a saved node" do
    
    before do
      @parent = Factory.create(:node)
      @parent.new_record?.should be(false)
      @child = Factory.create(:node)
      @child.new_record?.should be(false)
      @parent.children << @child
    end
    
    it "should be add a saved node to children" do
      
      @parent.children.first.should eq(@child)
    end
    
    context "when reloading the orm objects" do
      it "should be add a saved node to children" do
        @parent.reload.children.first.should eq(@child.reload)
      end
    end
    
    context "when fetching the objects to from the database" do
      it "should be add a saved node to children with reload" do
        Node.find(@parent.id).child_ids.first.should eq(@child.id)
        Node.find(@child.id).parent_ids.first.should eq(@parent.id)
      end
    end
   
  end
end