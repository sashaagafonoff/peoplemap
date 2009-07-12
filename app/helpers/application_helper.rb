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

end
