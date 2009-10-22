# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  caches_page :show, :graphml, :index

  around_filter :neo_tx
  after_filter :invalidate_cache,  :only => [:create, :update, :link, :unlink]

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'efb0b5600e8e340eb3584dabecb14b88'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  def linker(params)
    
    @origin = Neo4j.load(params[:origin_id])
    @target = Neo4j.load(params[:target_id])

    # construct predicate type
    @rel_string = params[:origin_type] + "_to_" + params[:target_type]

    case @rel_string
      when "person_to_person"
        rel = @origin.person_to_person.new(@target)        
      when "person_to_organisation"
        rel = @origin.person_to_organisation.new(@target)
      when "person_to_location"
        rel = @origin.person_to_location.new(@target)
      when "person_to_event"
        rel = @origin.person_to_event.new(@target)
      when "person_to_reference"
        rel = @origin.person_to_reference.new(@target)

      when "organisation_to_person"
        rel = @origin.organisation_to_person.new(@target)
      when "organisation_to_organisation"
        rel = @origin.organisation_to_organisation.new(@target)
      when "organisation_to_location"
        rel = @origin.organisation_to_location.new(@target)
      when "organisation_to_event"
        rel = @origin.organisation_to_event.new(@target)
      when "organisation_to_reference"
        rel = @origin.organisation_to_reference.new(@target)

      when "location_to_person"
        rel = @origin.location_to_person.new(@target)
      when "location_to_organisation"
        rel = @origin.location_to_organisation.new(@target)
      when "location_to_location"
        rel = @origin.location_to_location.new(@target)
      when "location_to_event"
        rel = @origin.location_to_event.new(@target)
      when "location_to_reference"
        rel = @origin.location_to_reference.new(@target)

      when "event_to_person"
        rel = @origin.event_to_person.new(@target)
      when "event_to_organisation"
        rel = @origin.event_to_organisation.new(@target)
      when "event_to_location"
        rel = @origin.event_to_location.new(@target)
      when "event_to_event"
        rel = @origin.event_to_event.new(@target)
      when "event_to_reference"
        rel = @origin.event_to_reference.new(@target)

       when "reference_to_person"
        rel = @origin.reference_to_person.new(@target)
      when "reference_to_organisation"
        rel = @origin.reference_to_organisation.new(@target)
      when "reference_to_location"
        rel = @origin.reference_to_location.new(@target)
      when "reference_to_event"
        rel = @origin.reference_to_event.new(@target)
      when "reference_to_reference"
        rel = @origin.reference_to_reference.new(@target)        

    end

    # relationship name (used for further domain reasoning eg direct family, wider family, etc)
    rel.name = params[:link_category]

    # date ranges for past/ongoing plus timeline visualisation
    rel.start_date = params[:start_date]
    rel.end_date = params[:end_date]

    # notes about the relationship
    unless params[:notes] == "<insert notes about this link here>" then
      rel.notes = params[:notes]
    end

  end
  
  def unlinker(params)
    @origin = Neo4j.load(params[:id]) if params[:id]
    @target = Neo4j.load(params[:target_id]) if params[:target_id]
    relationship = Neo4j.load_relationship(params[:neo_relationship_id])
    if (relationship) then
      relationship.delete
    end
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
  private

  def neo_tx
    Neo4j::Transaction.new
    yield
    Neo4j::Transaction.finish
  end

  def invalidate_cache
    cache_dir = ActionController::Base.page_cache_directory
    RAILS_DEFAULT_LOGGER.info "INVALIDATE CACHE #{cache_dir}"
    unless cache_dir == RAILS_ROOT+"/public"
      RAILS_DEFAULT_LOGGER.info "remove cache dir '#{cache_dir}'"
      FileUtils.rm_r(Dir.glob(cache_dir+"/*")) rescue Errno::ENOENT
      RAILS_DEFAULT_LOGGER.info("Cache directory '#{cache_dir}' fully swept.")
    end
  end
end
