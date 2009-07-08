# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def get_related_nodes(parent_id, relationship_type, depth)
    content_tag("ul")
    @parent = Neo4j.load(parent_id)
    content_tag("li", @parent.first_name)
    @parent.relationships.nodes.each do |child|
      @child = child
      if (child.neo_node_id != @parent.neo_node_id) then
        # output child name, rel type
        child.relationships.nodes.each do |grandchild|
          @grandchild = grandchild
          if (@parent.neo_node_id != grandchild.neo_node_id) then
            # output grandchild name
          end
        end
      end
    end
  end
  
end
