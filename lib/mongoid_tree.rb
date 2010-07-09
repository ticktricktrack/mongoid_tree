#require "mongoid"
module Mongoid
    module Acts
        module Tree
            extend ActiveSupport::Concern
            included do
                references_many :children, :class_name => "Node", :stored_as => :array, :inverse_of => :parent
                references_many :parent, :class_name => "Node", :stored_as => :array, :inverse_of => :children                
                
            end
        end
    end
end