# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def get_top_menu_style(controller_type)
    case controller_type.to_s
      when "PeopleController"
        @people_style = "color: #f1c130"
      when "OrganisationsController"
        @org_style = "color: #f1c130"
      when "EventsController"
        @event_style = "color: #f1c130"
      when "LocationsController"
        @location_style = "color: #f1c130"
      when "ReferencesController"
        @reference_style = "color: #f1c130"
    end
  end

  def relationship_date_range(edge)
    begin
      @start_date = edge.start_date.to_date.year.to_s
    rescue
      @start_date = " "
    end
    begin
      @end_date = edge.end_date.to_date.year.to_s
    rescue
      @end_date = " "
    end
    @date_range = "<span class='date_range'>(" + @start_date + " - " + @end_date + ")</span>"
  end

  def get_relationship_description(edge)

    case edge.start_node.class.to_s
      when "Person"
        if (edge.end_date == "" || edge.end_date > Date.today.to_s) then
          if (edge.start_node.sex == "Male") then
            @link_desc = "link_desc_male"
          else
            @link_desc = "link_desc_female"
          end
        else # for past relationships
          if (edge.start_node.sex == "Male") then
            @link_desc = "link_desc_male_past"
          else
            @link_desc = "link_desc_female_past"
          end
        end
      else
        if (edge.end_date == "" || edge.end_date > Date.today.to_s) then
          @link_desc = "link_desc_male"
        else
          @link_desc = "link_desc_male_past"
        end
    end
    xml = File.open("#{RAILS_ROOT}/config/relationships.xml")
    doc = Document.new(xml)
    @xpath_query = '//relationships/relationship[@name="' + edge.name + '"]/' + @link_desc
    @rel_desc = XPath.first(doc, @xpath_query).text

  end
  
  def get_type_list(origin_type, target_type)
    case # this annoying set of nested case statements switch the order for the purposes of matching against the rel types in relationships.xml
      when (origin_type == "organisation" and target_type == "person")
        origin_type = "person" 
        target_type = "organisation"
      when origin_type == "event"
        case target_type
          when "person"
            origin_type = "person" 
            target_type = "event"
          when "organisation"
            origin_type = "organisation"
            target_type = "event"
        end
      when origin_type == "location"
        case target_type
          when "person"
            origin_type = "person" 
            target_type = "location"
          when "organisation"
            origin_type = "organisation" 
            target_type = "location"
          when "event"
            origin_type = "event" 
            target_type = "location"
        end
      when origin_type == "reference"
        case target_type
          when "person"
            origin_type = "person" 
            target_type = "reference"
          when "organisation"
            origin_type = "organisation" 
            target_type = "reference"
          when "event"
            origin_type = "event" 
            target_type = "reference"
          when "location"
            origin_type = "location" 
            target_type = "reference"
        end
    end
    xml = File.open("#{RAILS_ROOT}/config/relationships.xml")
    doc = Document.new(xml)
    @drop_list_display = '//relationships/relationship[@subject="' + origin_type + '" and @object="' + target_type + '"]/option' # /text() will return just node values
    @drop_list_display_hash = XPath.match(doc, @drop_list_display)

    return @drop_list_display_hash
       
  end
  
 # generic traverser to 2 levels deep for entire link set - can easily replace with filtered search like /views/shared/_filtered_target.html.haml

  def convert_to_graphml(object)

    rel_array = Array.new
    children = Array.new

    # build GraphML for children nodes to target
    object.relationships.both.each do |relationship|

      grandchildren = Array.new
      rel_array.push(relationship.neo_relationship_id)

      @rel_start_id = relationship.start_node.neo_node_id
      @rel_end_id = relationship.end_node.neo_node_id
      @rel_id = relationship.neo_relationship_id
      unless (relationship.start_node.neo_node_id == 1) then  # relationships.both.each is returning an edge to node 1 which behaves strangely
        if (object.neo_node_id == relationship.start_node.neo_node_id) then inverse_node = relationship.end_node else inverse_node = relationship.start_node end

        inverse_node.relationships.both.each do |sub_relationship|
          unless (sub_relationship.start_node.neo_node_id == 1) then  
            unless rel_array.include? sub_relationship.neo_relationship_id then
              @inverse_id = inverse_node.neo_node_id
              @sub_rel_start_id = sub_relationship.start_node.neo_node_id
              @sub_rel_end_id = sub_relationship.end_node.neo_node_id
              @sub_rel_id = sub_relationship.neo_relationship_id
              if (inverse_node.neo_node_id == sub_relationship.start_node.neo_node_id) then sub_inverse_node = sub_relationship.end_node else sub_inverse_node = sub_relationship.start_node end
              @sub_edges = unless (sub_relationship.start_node.neo_node_id == 1) then graphml_edge_builder(sub_relationship) else " " end
              grandchildren.push graphml_builder(sub_inverse_node) + @sub_edges
            end
          end
          rel_array.push sub_relationship.neo_relationship_id
        end
      end

      @inverse_graphml = unless (inverse_node.nil?) then graphml_builder(inverse_node) else " " end    # need to catch 
      @grandchildren = grandchildren.join("")
      @edges = unless (relationship.start_node.neo_node_id == 1) then graphml_edge_builder(relationship) else " " end
      children.push @inverse_graphml + @grandchildren + @edges

      rel_array.push relationship.neo_relationship_id

    end
    @graphml = graphml_builder(object) + children.join("")
    #@graphml = rel_array.join(",")
  end
  
  # now detect class of target node and build data according to model
  def graphml_builder(node)
    case node.class.to_s
      when "Person"
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="name">' + [node.first_name, node.surname].join(" ") + '</data>
          <data key="first_name">' + (if(node.first_name=='') then 'EMPTY' else node.first_name end) + '</data>
          <data key="surname">' + (if(node.surname=='') then 'EMPTY' else node.surname end) + '</data>
          <data key="date_of_birth">' + (if(node.date_of_birth=='') then 'EMPTY' else node.date_of_birth end) + '</data>
          <data key="title">' + (if(node.title=='') then 'EMPTY' else node.title end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data> 
        </node>'  
      # :name, :sector, :industry, :notes
      when "Organisation"
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="name">' + (if(node.name=='') then 'EMPTY' else node.name end) + '</data>
          <data key="sector">' + (if(node.sector=='') then 'EMPTY' else node.sector end) + '</data>
          <data key="industry">' + (if(node.industry=='') then 'EMPTY' else node.industry end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>'  
      # :apt_office_floor_number, :street_number, :street_name, :street_type, :suburb, :city, :country, :postcode, :notes
      when "Location"
        text_address = [node.street_number,node.street_name,node.street_type,node.suburb].join(" ")
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="name">' + (if(text_address=='') then 'EMPTY' else text_address end) + '</data>
          <data key="apt_office_floor_number">' + (if(node.apt_office_floor_number=='') then 'EMPTY' else node.apt_office_floor_number end) + '</data>
          <data key="street_number">' + (if(node.street_number=='') then 'EMPTY' else node.street_number end) + '</data>
          <data key="street_name">' + (if(node.street_name=='') then 'EMPTY' else node.street_name end) + '</data>
          <data key="street_type">' + (if(node.street_type=='') then 'EMPTY' else node.street_type end) + '</data>
          <data key="suburb">' + (if(node.suburb=='') then 'EMPTY' else node.suburb end) + '</data>
          <data key="city">' + (if(node.city=='') then 'EMPTY' else node.city end) + '</data>
          <data key="country">' + (if(node.country=='') then 'EMPTY' else node.country end) + '</data>
          <data key="postcode">' + (if(node.postcode=='') then 'EMPTY' else node.postcode end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>'  
      # :title, :description, :event_type, :start_date, :end_date, :notes
      when "Event"
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="name">' + (if(node.title=='') then 'EMPTY' else node.title end) + '</data>
          <data key="description">' + (if(node.description=='') then 'EMPTY' else node.description end) + '</data>
          <data key="event_type">' + (if(node.event_type=='') then 'EMPTY' else node.event_type end) + '</data>
          <data key="start_date">' + (if(node.start_date=='') then 'EMPTY' else node.start_date end) + '</data>
          <data key="end_date">' + (if(node.end_date=='') then 'EMPTY' else node.end_date end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>
        '  
      # :reference_type, :ref_value, :notes
      when "Reference"
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="name">' + (if(node.ref_value=='') then 'EMPTY' else node.ref_value end) + '</data>
          <data key="reference_type">' + (if(node.reference_type=='') then 'EMPTY' else node.reference_type end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>'  
    end
  end
  
  def graphml_edge_builder(edge)
    @rel_desc = get_relationship_description(edge)
    #@rel_desc = "unknown"
    '<edge source="' + edge.start_node.neo_node_id.to_s +
       '" target="' + edge.end_node.neo_node_id.to_s + '"
       link_type="'+ @rel_desc +'">
     </edge>'
  end
  
end
