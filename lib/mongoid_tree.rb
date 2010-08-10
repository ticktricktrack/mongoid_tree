module Mongoid
    module Acts
        module Tree
            extend ActiveSupport::Concern
            include Comparable

            included do
                references_many :children, :class_name => self.name, :stored_as => :array, :inverse_of => :parent do
                    def <<(*objects)
                        objects.flatten.each_with_index do |object, index|
                            if object.position == nil
                                object.position = @parent.send(@foreign_key).count + index + 1
                            end
                        end
                        super(objects)
                    end
                end
                
                referenced_in :parent, :class_name  => self.name, :inverse_of => :children
                
                # This stores the position in the children array of the parent object.
                # Makes it easier to flatten / export / import a tree
                field :position, :type => Integer
            end

            module InstanceMethods
                
                #Comparable
                def <=> (another_node)
                    self.position <=> another_node.position
                end

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
                    self.save
                    self.parent.save
                    new_child.position = self.position
                    self.parent.children.each do |child|
                        if child.position >= new_child.position
                            child.position += 1
                        end
                    end
                    self.parent.children << new_child 
                end
            end



        end
    end
end