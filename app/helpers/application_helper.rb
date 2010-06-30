# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def get_top_menu_style(controller_type)
    case controller_type.to_s
      when "PeopleController"
        @people_style = "color: #f1c130;"
      when "OrganisationsController"
        @org_style = "color: #f1c130;"
      when "EventsController"
        @event_style = "color: #f1c130;"
      when "LocationsController"
        @location_style = "color: #f1c130;"
      when "ReferencesController"
        @reference_style = "color: #f1c130;"
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
    if (edge.end_date == "" || edge.end_date > Date.today.to_s) then
      @link_desc = "link_desc"
    else # for past relationships
      @link_desc = "link_desc_past"
    end
    @@cache ||= {}
    unless @@cache[edge.name]
      xml = File.open("#{RAILS_ROOT}/config/relationships.xml")
      doc = Document.new(xml)
      @edge_name = edge.name
      xpath_query = '//relationships/relationship[@name="' + @edge_name + '"]/' + @link_desc
      @@cache[edge.name] = XPath.first(doc, xpath_query).text
      xml.close
    end
    @rel_desc = @@cache[edge.name]
  end
  
  def get_type_list(origin_type, target_type, origin_gender)
    @@cache2 ||= {}
    key = origin_type + target_type + origin_gender
    case origin_gender
      when "Male"
        @gender_modifier = ' and (@gender_specific="male" or @gender_specific="neutral")'
      when "Female"
        @gender_modifier = ' and (@gender_specific="female" or @gender_specific="neutral")'
      else
        @gender_modifier = ''
    end
    unless @@cache2[key]
      xml = File.open("#{RAILS_ROOT}/config/relationships.xml")
      doc = Document.new(xml)
      drop_list_display = '//relationships/relationship[@predicate="' + origin_type + '_to_' + target_type + '"'+ @gender_modifier +']/option' # /text() will return just node values
      @@cache2[key] = XPath.match(doc, drop_list_display)
      xml.close
    end
    return @@cache2[key]
  end

  def get_gender(object)
    if object.class.to_s == "Person" then
      if (object.sex.nil?) then "neutral" else object.sex end
    else
      "neutral"
    end
  end

 # generic traverser to 2 levels deep for entire link set - can easily replace with filtered traversals using both(:link_type)

  def convert_to_graphml(object)

    node_array = Array.new # need to track node IDs to avoid duplication in the generated GraphML
    rel_array = Array.new  # need to track relationships to avoid recursion
    children = Array.new

    # build GraphML for children nodes to target
    object.rels.both.each do |relationship|

      grandchildren = Array.new
      rel_array.push(relationship.neo_id)

      @rel_start_id = relationship.start_node.neo_id
      @rel_end_id = relationship.end_node.neo_id
      @rel_id = relationship.neo_id

      unless (relationship.start_node.neo_id == 1) then  # relationships.both.each is returning an edge to node 1 which behaves strangely - THIS IS A HACK

        # inverse_node is the node to which our originating node connects (relationship could be incoming or outgoing)
        if (object.neo_id == relationship.start_node.neo_id) then inverse_node = relationship.end_node else inverse_node = relationship.start_node end

        inverse_node.rels.both.each do |sub_relationship|
          unless (sub_relationship.start_node.neo_id == 1) then # rels.both.each is returning an edge to node 1 which behaves strangely - THIS IS A HACK
            unless rel_array.include? sub_relationship.neo_id then

              # find out which node is the other end of the relationship from the originating node
              if (inverse_node.neo_id == sub_relationship.start_node.neo_id) then sub_inverse_node = sub_relationship.end_node else sub_inverse_node = sub_relationship.start_node end

              # build graphml code for node and edge (unless already done)
              @sub_nodes = unless (node_array.include? sub_inverse_node.neo_id) then graphml_builder(sub_inverse_node) else " " end  # else " " is needed to stop stuff breaking
              @sub_edges = unless (sub_relationship.start_node.neo_id == 1) then graphml_edge_builder(sub_relationship) else " " end

              # push to array of sub-code for second layer
              grandchildren.push @sub_nodes + @sub_edges

              # finally, keep track of this node to stop it repeating
              node_array.push sub_inverse_node.neo_id # add inverse node to list to stop it repeating
            end
          end
          rel_array.push sub_relationship.neo_id
        end
      end

      @inverse_node_graphml = unless (inverse_node.nil?) then
        unless (node_array.include? inverse_node.neo_id) then graphml_builder(inverse_node) else " " end
      else
        " "
      end
      @grandchildren = grandchildren.join("")
      @edges = unless (relationship.start_node.neo_id == 1) then graphml_edge_builder(relationship) else " " end
      children.push @inverse_node_graphml + @grandchildren + @edges

      rel_array.push relationship.neo_id

    end
    @graphml = graphml_builder(object) + children.join("")
    
  end

  # now detect class of target node and build data according to model
  def graphml_builder(node)
    case node.class.to_s
      when "Person"
       '<node id="' + node.neo_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="title">' + (if(node.title=='') then 'EMPTY' else node.title end) + '</data>
          <data key="name">' + [node.first_name, node.surname].join(" ") + '</data>
          <data key="first_name">' + (if(node.first_name=='') then 'EMPTY' else node.first_name end) + '</data>
          <data key="surname">' + (if(node.surname=='') then 'EMPTY' else node.surname end) + '</data>
          <data key="sex">' + (if(node.sex=='') then 'EMPTY' else node.sex end) + '</data>
          <data key="date_of_birth">' + (if(node.date_of_birth=='') then 'EMPTY' else node.date_of_birth end) + '</data>
          <data key="facebook_uid">' + (if(node.title=='') then 'EMPTY' else node.facebook_uid end) + '</data>
          <data key="twitter_screen_name">' + (if(node.title=='') then 'EMPTY' else node.twitter_screen_name end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>'  
      # :name, :sector, :industry, :notes
      when "Organisation"
       '<node id="' + node.neo_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="name">' + (if(node.name=='') then 'EMPTY' else node.name end) + '</data>
          <data key="sector">' + (if(node.sector=='') then 'EMPTY' else node.sector end) + '</data>
          <data key="industry">' + (if(node.industry=='') then 'EMPTY' else node.industry end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>'  
      # :apt_office_floor_number, :street_number, :street_name, :street_type, :suburb, :city, :country, :postcode, :notes
      when "Location"
        text_address = [node.street_number,node.street_name,node.street_type,node.suburb].join(" ")
       '<node id="' + node.neo_id.to_s + '">
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
       '<node id="' + node.neo_id.to_s + '">
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
       '<node id="' + node.neo_id.to_s + '">
          <data key="node_class">' + node.class.to_s.downcase + '</data>
          <data key="name">' + (if(node.ref_value=='') then 'EMPTY' else node.ref_value end) + '</data>
          <data key="reference_type">' + (if(node.reference_type=='') then 'EMPTY' else node.reference_type end) + '</data>
          <data key="notes">' + (if(node.notes=='') then 'EMPTY' else node.notes end) + '</data>
        </node>'  
    end
  end
  
  def graphml_edge_builder(edge)
    @rel_desc = get_relationship_description(edge)
    @start_date = edge.start_date
    @end_date = edge.end_date
    @notes = edge.notes
#    if (edge.start_date.nil?) then @start_date = "" else @start_date = edge.start_date end
#    if (edge.end_date=="") then @end_date ="" else @end_date = edge.end_date end
#    if (edge.notes=="") then @notes = "" else @notes = =  edge.notes end
    #@rel_desc = "unknown"
    '<edge id = "' + edge.neo_id.to_s +
       '" source="' + edge.start_node.neo_id.to_s +
       '" target="' + edge.end_node.neo_id.to_s +
       '" link_type="' + @rel_desc +
       '" start_date="' + @start_date +
       '" end_date="' + @end_date +
       '" notes="' + @notes +
       '">
     </edge>'
  end

  def get_display_name(object)
    case object.class.to_s
      when "Person"
        @display_name = [object.first_name,object.surname].join(" ")
      when "Organisation"
        @display_name = object.name
      when "Location"
        @display_name = [object.street_number,object.street_name,object.street_type,object.suburb,object.city,object.country].join(" ")
      when "Event"
        @display_name = object.title
      when "Reference"
        @display_name = object.ref_value
    end

    return @display_name
  end

  def search_index(class_type,search_term)
    case class_type
      when "person"
        @people = Person.find(:first_name=>search_term)
        @people2 = Person.find(:surname=>search_term)
      when "organisation"
        @organisations = Organisation.find(:name=>search_term)
      when "location"
        @locations = Location.find(:street_name=>search_term)
      when "event"
        @events = Event.find(:title=>search_term)
      when "reference"
        @references = Reference.find(:ref_value=>search_term)
    end
  end

  def search_terms_display(search_terms)
    unless (search_terms.nil?) then
      if search_terms.kind_of? Array then
        @search_terms_display = search_terms.join(" ")
      else
        @search_terms_display = search_terms 
      end
    else
      @search_terms_display = ""
    end
    return @search_terms_display
  end

  def load_batch_data
#    xml = File.open("#{RAILS_ROOT}/public/batch.xml")
#    doc = Document.new(xml)
#    xpath_query = '//relationships/relationship[@name="' + @edge_name + '"]/' + @link_desc
#    xml.close
  end

  def batch_create_node

  end

  def batch_link_node

  end

end
