class EventsController < ApplicationController
  
  around_filter :neo_tx
  layout 'layout', :except => [:graphml]
  
  def index
    @events = Event.all.nodes
  end
  
  def create
    @object = Event.new
    @object.update(params[:event])
    flash[:notice] = 'Event was successfully created.'
    redirect_to(events_url)
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
    flash[:notice] = @object.title + " was linked to node " + @target.neo_node_id.to_s
  end
  
  def unlink
    unlinker(params)
    redirect_to(@object)
    flash[:notice] = @object.title + " was unlinked from " + @target.neo_node_id.to_s
  end
  
  def new
    @object = Event.value_object.new
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