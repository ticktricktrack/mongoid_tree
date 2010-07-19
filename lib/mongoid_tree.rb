#require "mongoid"
module Mongoid
    module Acts
        module Tree
            extend ActiveSupport::Concern

            included do
                references_many :children, :class_name => self.name, :stored_as => :array, :inverse_of => :parent
                references_many :parent, :class_name => self.name, :stored_as => :array, :inverse_of => :children

                def depth_first
                    result = [self]
                    if children.empty?
                        return result
                    else
                        self.children.each do |child|
                            result += child.depth_first
                        end    
                    end
                    return result                    
                end
                
                
                # This is a temporary method name until Mongoid supports references_many :as => array 
                # as a single sided association
                def get_parent
                    return parent.first
                end

            end
        end
    end
end