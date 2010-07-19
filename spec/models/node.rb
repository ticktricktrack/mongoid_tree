class Node
    include Mongoid::Document
    include Mongoid::Acts::Tree
   
    field :name
end