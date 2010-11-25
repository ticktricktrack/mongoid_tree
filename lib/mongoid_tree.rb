module Mongoid
    module Acts
        module Tree
            extend ActiveSupport::Concern
            include Comparable

            included do
                references_many :children, 
                :class_name => self.name, 
                :stored_as => :array, 
                :inverse_of => :parents,
                :dependent => :destroy do
                    def <<(*objects)
                        # in this version I did not call super, but instead copy the code from the mongoid gem in here
                        # I had some persistence fails on saved objects so I'm trying it this way now
                        @target = @target.entries
                        objects.flatten.each_with_index do |object, index|
                            reverse_key = reverse_key(object)
                            if object.position == nil
                                # This one sets the position for a new object added via children << object
                                object.position = @parent.send(@foreign_key).count + index + 1
                            end
                            # Stores the parents path into it's own path array.
                            #raise @parent.inspect
                            object.send(reverse_key).concat(@parent.send(reverse_key))
                            # object.save unless @parent.new_record?
                            # First set the documents id on the parent array of ids.
                            @parent.send(@foreign_key) << object.id
                            # Then we need to set the parent's id on the documents array of ids
                            # to get the inverse side of the association as well. Note, need a
                            # clean way to handle this with new documents - we want to set the
                            # actual objects as well, but dont want to get in an infinite loop
                            # while doing so.

                            if inverse?
                                reverse_key = reverse_key(object)
                                case inverse_of(object).macro
                                when :references_many
                                    object.send(reverse_key) << @parent.id
                                when :referenced_in
                                    object.send("#{reverse_key}=", @parent.id)
                                end
                            end
                            @target << object
                            object.save unless @parent.new_record?

                        end  
                        @parent.save unless @parent.new_record?                      
                        # super(objects)                        
                    end
                end

                references_many :parents, 
                :class_name => self.name, 
                :stored_as => :array, 
                :inverse_of => :children

                # This stores the position in the children array of the parent object.
                # Makes it easier to flatten / export / import a tree
                field :position, :type => Integer
            end

            module InstanceMethods
                
                
                def parent
                    parents.last
                end

                def depth
                    parent_ids.count
                end
                
                def leaf?
                   child_ids.empty?
                end

                def root?
                  parent_ids.empty?
                end
                
                def root
                  base_class.find(parent_ids.first) unless root?
                end
                
                def ancestors
                  base_class.where(:_id.in => parent_ids)
                end
                
                def ancestors_and_self
                  ancestors << self
                end

                #Comparable
                def <=> (another_node)
                    position <=> another_node.position
                end

                # Returns the whole subtree including itself as array
                def depth_first
                    result = [self]
                    if child_ids.empty?
                        return result
                    else
                        children.sort.each do |child|
                            result += child.depth_first
                        end    
                    end
                    return result                    
                end
                alias :dfs :depth_first

                # Returns the whole subtree including itself as array
                def breadth_first
                    result = []
                    queue = [self]
                    while !queue.empty?
                        node = queue.shift
                        result << node
                        node.children.sort.each do |child|
                            queue << child
                        end
                    end
                    return result
                end
                alias :bfs :breadth_first

                def insert_before( new_child )
                    new_child.position = position
                    parent.children.each do |child|
                        if child.position >= new_child.position
                            child.update_attributes(:position => child.position + 1)
                        end
                    end
                    parent.children << new_child
                end

                def insert_after ( new_child )
                    new_child.position = position + 1
                    parent.children.each do |child|
                        if child.position >= new_child.position
                            child.update_attributes(:position => child.position + 1)
                        end
                    end
                    parent.children << new_child
                end
                
                def unhinge
                  # unhinge - I was getting a nil on another implementation, so this is a bit longer but works
                  child_ids_array = parent.child_ids.clone
                  child_ids_array.delete(id)
                  parent.update_attributes(:child_ids => child_ids_array )
                  self.update_attributes(:parent_ids => [], :position => nil )
                end

                def move_to(target_node)
                    # unhinge - I was getting a nil on another implementation, so this is a bit longer but works
                    unhinge
                    # and append
                    target_node.children << self
                    # recurse through subtree
                    rebuild_paths
                end
                
                def move_to_position(target_node, index)
                  if index > target_node.child_ids.count
                    move_to(target_node)
                  else
                    # unhinge - I was getting a nil on another implementation, so this is a bit longer but works
                    child_ids_array = parent.child_ids.clone
                    child_ids_array.delete(id)
                    parent.update_attributes(:child_ids => child_ids_array )
                    self.update_attributes(:parent_ids => [], :position => nil )
                    
                    target_node.children.sort[index - 1].insert_before(self)
                    
                    # recurse through subtree
                    rebuild_paths
                  end
                end
                

                def rebuild_paths
                    update_path
                    children.each do |child|
                        child.rebuild_paths
                    end
                end

                def update_path
                    self.update_attributes(:parent_ids => self.parent.parent_ids + [self.parent.id])
                end
                
                def base_class
                  @base_class ||= begin
                    parent_classes = self.class.ancestors
                    parent_classes[parent_classes.index(Mongoid::Acts::Tree::InstanceMethods) - 1]
                  end
                end

            end
        end
    end
end
