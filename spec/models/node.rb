class Node
    include Mongoid::Document
    include Mongoid::Acts::Tree
   
    field :name
    
    validates_presence_of :name
end