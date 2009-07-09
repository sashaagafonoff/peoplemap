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
    @date_range = relationship.start_date + " - " + relationship.end_date
  end

end
