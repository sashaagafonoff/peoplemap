class EventsController < ApplicationController
  
  around_filter :neo_tx
  layout 'layout', :except => [:graphml]
  
  def index
    @events = Event.all.nodes
    @current_node_icon = "/images/icons/event.png"
  end
  
  def create
    @object = Event.new
    @object.update(params[:event])
    flash[:notice] = 'Event was successfully created.'
    redirect_to(@object)
  end
  
  def update
    @object.update(params[:event])
    flash[:notice] = 'Event was successfully updated.'
    redirect_to(@object)
  end
  
  def destroy
    @object.delete
    redirect_to(events_url)
  end
  
  def edit
    @form_explanation = "This form will update the record.  Click <strong>Update</strong> to save it."
    @form_operation = "Update Event"
    @current_node_icon = "/images/icons/event.png"
  end
  
  def show
    @references = Reference.all.nodes
    @organisations = Organisation.all.nodes
    @people = Person.all.nodes
    @locations = Location.all.nodes
    @events = Event.all.nodes
    @current_node_icon = "/images/icons/event.png"
  end

  def link
    linker(params)
    redirect_to(@object)
    flash[:notice] = get_display_name(@object) + " was linked to " + get_display_name(@target)
  end
  
  def unlink
    unlinker(params)
    redirect_to(@object)
    flash[:notice] = get_display_name(@object) + " was unlinked " + get_display_name(@target)
  end
  
  def new
    @object = Event.value_object.new
    @form_explanation = "This will create a new event record.  Click <strong>Update</strong> to add it to the system."
    @form_operation = "Create Event"
    @current_node_icon = "/images/icons/event.png"
  end
  
  def graphml
  end

  private
  def neo_tx
    Neo4j::Transaction.new
    @object = Neo4j.load(params[:id]) if params[:id]
    yield
    Neo4j::Transaction.finish
  end
end