class LocationsController < ApplicationController
  
  layout 'layout', :except => [:graphml]
  
  def index
    @locations = Location.all.nodes
    @current_node_icon = "/images/icons/location.png"
  end
  
  def create
    @object = Location.new
    @object.update(params[:location])
    flash[:notice] = 'Location was successfully created.'
    redirect_to(@object)
  end
  
  def update
    @object.update(params[:location])
    flash[:notice] = 'Location was successfully updated.'
    redirect_to(@object)
  end
  
  def destroy
    @object.delete
    redirect_to(locations_url)
  end
  
  def edit
    @form_explanation = "This form will update the record.  Click <strong>Update</strong> to save it."
    @form_operation = "Update Location"
    @current_node_icon = "/images/icons/location.png"
  end
  
  def show
    @references = Reference.all.nodes
    @organisations = Organisation.all.nodes
    @people = Person.all.nodes
    @locations = Location.all.nodes
    @events = Event.all.nodes
    @current_node_icon = "/images/icons/location.png"

  end

  def link
    linker(params)
    redirect_to(@object)
    flash[:notice] = @object.neo_node_id.to_s + " was linked to node " + @target.neo_node_id.to_s
  end
  
  def unlink
    unlinker(params)
    redirect_to(@object)
    flash[:notice] = @object.neo_node_id.to_s + " was unlinked from " + @target.neo_node_id.to_s
  end
  
  def new
    @object = Location.value_object.new
    @form_explanation = "This will create a new person record.  Click <strong>Update</strong> to add it to the system."
    @form_operation = "Create Location"
    @current_node_icon = "/images/icons/location.png"
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