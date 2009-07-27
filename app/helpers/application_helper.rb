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
    @date_range = "| <span class='date_range'>(" + @start_date + " - " + @end_date + ")</span>"
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
    xml = File.open('config/relationships.xml')
    case
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
    doc = Document.new(xml)
    @drop_list_display = '//relationships/relationship[@subject="' + origin_type + '" and @object="' + target_type + '"]/option' # /text() will return just node values
    @drop_list_display_hash = XPath.match(doc, @drop_list_display)

    return @drop_list_display_hash
       
  end
  
end
