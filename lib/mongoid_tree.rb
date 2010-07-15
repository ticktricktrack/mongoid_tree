#require "mongoid"
module Mongoid
  module Acts
    module Tree
      extend ActiveSupport::Concern
      
      included do
        references_many :children, :class_name => self.class.to_s, :stored_as => :array, :inverse_of => :parent
        references_many :parent, :class_name => self.class.to_s, :stored_as => :array, :inverse_of => :children                 
        end
      end
    end
  end
end