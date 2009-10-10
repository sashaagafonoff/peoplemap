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

  def relationship_date_range(relationship)
    begin
      @start_date = relationship.start_date.to_date.year.to_s
    rescue
      @start_date = " "
    end
    begin
      @end_date = relationship.end_date.to_date.year.to_s
    rescue
      @end_date = " "
    end
    @date_range = "<span class='date_range'>(" + @start_date + " - " + @end_date + ")</span>"
  end

  def get_relationship_description(object) 

    case controller.type.to_s
      when "PeopleController"
        if (object.end_date == "" || object.end_date > Date.today.to_s) then
          if (object.start_node.sex == "Male") then
            @link_desc = "link_desc_male"
          else
            @link_desc = "link_desc_female"
          end
        else # for past relationships
          if (object.start_node.sex == "Male") then
            @link_desc = "link_desc_male_past"
          else
            @link_desc = "link_desc_female_past"
          end
        end
      else
        if (object.end_date == "" || object.end_date > Date.today.to_s) then
          @link_desc = "link_desc_male"
        else
          @link_desc = "link_desc_male_past"
        end
    end
    xml = File.open('config/relationships.xml')
    doc = Document.new(xml)
    @xpath_query = '//relationships/relationship[@name="' + object.name + '"]/' + @link_desc
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
            origin_type = "person" 
            target_type = "organisation"
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
    xml = File.open('config/relationships.xml')
    doc = Document.new(xml)
    @drop_list_display = '//relationships/relationship[@subject="' + origin_type + '" and @object="' + target_type + '"]/option' # /text() will return just node values
    @drop_list_display_hash = XPath.match(doc, @drop_list_display)

    return @drop_list_display_hash
       
  end
  
 # generic traverser to 2 levels deep for entire link set - can easily replace with filtered search like /views/shared/_filtered_target.html.haml

  def convert_to_graphml(object)
    children = Array.new
    members = Array.new
    members.push object.neo_node_id
    # build GraphML for children nodes to target
    object.relationships.each do |relationship|
      grandchildren = Array.new
      # build GraphML for grandchildren nodes to target
      # HEY THIS CODE IS WRONG YOU CAN'T GUARANTEE THAT IT IS ALWAYS AN END NODE IT COULD BE A REVERSE LINK
      relationship.end_node.relationships.each do |subrelationship|
        unless members.include? subrelationship.end_node.neo_node_id then
          grandchildren.push graphml_builder(subrelationship.end_node) + graphml_edge_builder(subrelationship)
        end
        members.push subrelationship.end_node.neo_node_id
      end
      unless members.include? relationship.end_node.neo_node_id then
        children.push graphml_builder(relationship.end_node) + grandchildren.join("") + graphml_edge_builder(relationship)
      end
      members.push relationship.end_node.neo_node_id
    end
    @graphml = graphml_builder(object) + children.join("")
  end
  
  # now detect class of target node and build data according to model
  def graphml_builder(node)
    case node.class.to_s
      when "Person"
       '<node id="' + node.neo_node_id.to_s + '">' +
        '<data key="node_class">' + node.class.to_s.downcase + '</data>
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
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
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
          <data key="title">' + (if(node.title=='') then 'EMPTY' else node.title end) + '</data>
          <data key="description">' + (if(node.description=='') then 'EMPTY' else node.description end) + '</data>
          <data key="type">' + (if(node.event_type=='') then 'EMPTY' else node.event_type end) + '</data>
          <data key="start_date">' + (if(node.start_date=='') then 'EMPTY' else node.start_date end) + '</data>
          <data key="end_date">' + (if(node.end_date=='') then 'EMPTY' else node.end_date end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>
        '  
      # :reference_type, :ref_value, :notes
      when "Reference"
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="reference_type">' + (if(node.reference_type=='') then 'EMPTY' else node.reference_type end) + '</data>
          <data key="ref_value">' + (if(node.ref_value=='') then 'EMPTY' else node.ref_value end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>'  
    end
  end
  
  def graphml_builder_old(node)
    case node.class.to_s
      when "Person"
       '<node id="' + node.neo_node_id.to_s + '">' +
        '<data key="node_class">' + node.class.to_s.downcase + '</data>
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
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
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
          <data key="title">' + (if(node.title=='') then 'EMPTY' else node.title end) + '</data>
          <data key="description">' + (if(node.description=='') then 'EMPTY' else node.description end) + '</data>
          <data key="type">' + (if(node.event_type=='') then 'EMPTY' else node.event_type end) + '</data>
          <data key="start_date">' + (if(node.start_date=='') then 'EMPTY' else node.start_date end) + '</data>
          <data key="end_date">' + (if(node.end_date=='') then 'EMPTY' else node.end_date end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>
        '  
      # :reference_type, :ref_value, :notes
      when "Reference"
       '<node id="' + node.neo_node_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="type">' + (if(node.reference_type=='') then 'EMPTY' else node.reference_type end) + '</data>
          <data key="value">' + (if(node.ref_value=='') then 'EMPTY' else node.ref_value end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>'  
    end
  end
  
  def graphml_edge_builder(edge)
    '<edge source="' + edge.start_node.neo_node_id.to_s + 
            '" target="' + edge.end_node.neo_node_id.to_s + '">
          </edge>'
  end
  
 # generic traverser to 2 levels deep for entire link set - can easily replace with filtered search like /views/shared/_filtered_target.html.haml
  
  def convert_to_json(object)
    children = Array.new
    members = Array.new
    members.push object.neo_node_id
    # build JSON for children nodes to target
    object.relationships.each do |relationship|
      grandchildren = Array.new
      # build JSON for grandchildren nodes to target
      # HEY THIS CODE IS WRONG YOU CAN'T GUARANTEE THAT IT IS ALWAYS AN END NODE IT COULD BE A REVERSE LINK
      relationship.end_node.relationships.each do |subrelationship|
        unless members.include? subrelationship.end_node.neo_node_id then
          grandchildren.push JSON_builder(subrelationship.end_node) + '}'
        end
        members.push subrelationship.end_node.neo_node_id
      end
      unless members.include? relationship.end_node.neo_node_id then
        children.push JSON_builder(relationship.end_node) + ',"children" : [' + grandchildren.join(",") + ']}'
      end
      members.push relationship.end_node.neo_node_id
    end
    @json = JSON_builder(object) + ',"children" : [' + children.join(",") + ']}'
  end
  # now detect class of target node and build data according to model
  def JSON_builder(node)
    case node.class.to_s
      when "Person"
         '{
          "id":  "' + node.neo_node_id.to_s + '",
          "name" : "' + [node.first_name, node.surname].join(" ") + '",
          "data" : [
            { "Class" : "' + node.class.to_s.downcase + '"},
            { "First Name" : "' + node.first_name + '"},
            { "Surname" : "' + node.surname + '"},
            { "Date Of Birth" : "' + node.date_of_birth + '"},
            { "Title" : "' + node.title + '"},
            { "Notes" : "' + node.notes + '"} 
          ]'  
      # :name, :sector, :industry, :notes
      when "Organisation"
         '{
          "id":  "' + node.neo_node_id.to_s + '",
          "name" : "' + node.name + '",
          "data" : [
            { "Class" : "' + node.class.to_s.downcase + '"},
            { "Name" : "' + node.name + '"},
            { "Sector" : "' + node.sector + '"},
            { "Industry" : "' + node.industry + '"},
            { "Notes" : "' + node.notes + '"} 
          ]'  
      # :apt_office_floor_number, :street_number, :street_name, :street_type, :suburb, :city, :country, :postcode, :notes
      when "Location"
         '{
          "id":  "' + node.neo_node_id.to_s + '",
          "name" : "' + [node.street_number,node.street_name,node.street_type,node.suburb].join(" ") + '",
          "data" : [
            { "Class" : "' + node.class.to_s.downcase + '"},
            { "Name" : "' + node.apt_office_floor_number + '"},
            { "Name" : "' + node.street_number + '"},
            { "Name" : "' + node.street_name + '"},
            { "Name" : "' + node.street_type + '"},
            { "Name" : "' + node.suburb + '"},
            { "Name" : "' + node.city + '"},
            { "Name" : "' + node.country + '"},
            { "Name" : "' + node.postcode + '"},
            { "Notes" : "' + node.notes + '"} 
          ]'  
      # :title, :description, :event_type, :start_date, :end_date, :notes
      when "Event"
         '{
          "id":  "' + node.neo_node_id.to_s + '",
          "name" : "' + node.title + '",
          "data" : [
            { "Class" : "' + node.class.to_s.downcase + '"},
            { "Title" : "' + node.title + '"},
            { "Description" : "' + node.description + '"},
            { "Type" : "' + node.event_type + '"},
            { "Start Date" : "' + node.start_date + '"},
            { "End Date" : "' + node.end_date + '"},
            { "Notes" : "' + node.notes + '"} 
          ]'  
      # :reference_type, :ref_value, :notes
      when "Reference"
         '{
          "id":  "' + node.neo_node_id.to_s + '",
          "name" : "' + node.ref_value + '",
          "data" : [
            { "Class" : "' + node.class.to_s.downcase + '"},
            { "Type" : "' + node.reference_type + '"},
            { "Value" : "' + node.ref_value + '"},
            { "Notes" : "' + node.notes + '"} 
          ]'  
    end
  end

end
