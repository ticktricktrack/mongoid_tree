module Mongoid
    module Acts
        module Tree
            extend ActiveSupport::Concern

            included do
                references_many :children, :class_name => self.name, :stored_as => :array, :inverse_of => :parent
                referenced_in :parent, :class_name  => self.name, :reverse_of => :children

                # field :parent_id
                # field :children_ids
            end

            module InstanceMethods

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


                def insert_before( new_child )
                    new_child.position = self.position
                    self.parent.children.each do |child|
                        if child.position >= new_child.position
                            child.position += 1
                        end
                    end
                    self.parent.children << new_child 
                end

                def insert_after ( new_child )
                    self.parent.children << new_child 
                end

            end



        end
    end
end