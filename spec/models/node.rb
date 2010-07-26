class Node
    include Mongoid::Document
    include Mongoid::Acts::Tree
    include Comparable
   
    field :name

    # This stores the position in the children array of the parent object.
    # Makes it easier to flatten / export / import a tree
    field :position, :type => Integer, :default => 1
    
    validates_presence_of :name
    
    # Comparable
    def <=> (another_node)
        self.position <=> another_node.position
    end
    
end