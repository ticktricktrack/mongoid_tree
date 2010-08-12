module Mongoid
    module Acts
        module Tree
            extend ActiveSupport::Concern
            include Comparable

            included do
                references_many :children, :class_name => self.name, :stored_as => :array, :inverse_of => :parents do
                    def <<(*objects)
                        objects.flatten.each_with_index do |object, index|
                            reverse_key = reverse_key(object)
                            if object.position == nil
                                # This one sets the position for a new object added via children << object
                                object.position = @parent.send(@foreign_key).count + index + 1
                            end
                            # Stores the parents path into it's own path array.
                            #raise @parent.inspect
                            object.send(reverse_key).concat(@parent.send(reverse_key))
                        end
                        super(objects)

                    end
                end

                references_many :parents, :class_name => self.name, :stored_as => :array, :inverse_of => :children

                # This stores the position in the children array of the parent object.
                # Makes it easier to flatten / export / import a tree
                field :position, :type => Integer
                field :depth, :type => Integer
            end

            module InstanceMethods

                def parent
                    self.parents.last
                end

                def depth
                    self.parents.count
                end

                #Comparable
                def <=> (another_node)
                    self.position <=> another_node.position
                end


                # TODO change this into a Mongoid Query, if possible
                def depth_first
                    result = [self]
                    if children.empty?
                        return result
                    else
                        self.children.sort.each do |child|
                            result += child.depth_first
                        end    
                    end
                    return result                    
                end

                def breadth_first
                    queue = [self]
                    while !queue.empty?
                        node = queue.shift
                        node.children.sort.each do |child|
                            queue << child
                        end
                    end
                end
                
                def insert_before( new_child )
                    new_child.position = self.position
                    self.parent.children.each do |child|
                        if child.position >= new_child.position
                            child.position += 1
                        end
                    end
                    self.parent.reload.children << new_child
                end

                def insert_after ( new_child )
                    new_child.position = self.position + 1
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