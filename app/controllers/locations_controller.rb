class LocationsController < ApplicationController
  
  around_filter :neo_tx
  layout 'layout', :except => [:graphml]
  
  def index
    @locations = Location.all.nodes
  end
  
  def create
    @object = Neo4j::Location.new
    @object.update(params[:location])
    flash[:notice] = 'Location was successfully created.'
    redirect_to(locations_url)
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
  end
  
  def show
    @references = Reference.all.nodes
    @organisations = Organisation.all.nodes
    @people = Person.all.nodes
    @locations = Location.all.nodes
    @events = Event.all.nodes

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