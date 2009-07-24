class EventsController < ApplicationController
  before_filter :find_event, :only => [:show, :edit, :update, :destroy]
  around_filter :neo_tx
  layout 'layout'
  
  def index
    @events = Event.all.nodes
  end
  
  def create
    @event = Neo4j::Event.new
    @event.update(params[:event])
    flash[:notice] = 'event was successfully created.'
    redirect_to(events_url)
  end
  
  def update
    @event.update(params[:event])
    flash[:notice] = 'event was successfully updated.'
    redirect_to(@event)
  end
  
  def destroy
    @event.delete
    redirect_to(events_url)
  end
  
  def edit
  end
  
  def show
    @event = Neo4j.load(params[:id])
    
    @references = Reference.all.nodes
    @organisations = Organisation.all.nodes
    @people = Person.all.nodes
    @locations = Location.all.nodes
    @events = Event.all.nodes

    if params[:target_id]
      
      @target = Neo4j.load(params[:target_id])
      
      if params[:unlink] then
        @target = Neo4j.load(params[:target_id])
        if (@event.relationships[@target]) then
          @event.relationships[@target].delete
        end
        if (@target.relationships[@event]) then
          @target.relationships[@event].delete
        end
        flash[:notice] = @target.neo_node_id + ' was successfully unlinked.'
      else
        case params[:link_type]
          when "address_of"
            rel1 = @event.address_of.new(@target)
            rel2 = @target.address_of.new(@event) 
            rel1.link_desc_en = "is occurring at"
            rel2.link_desc_en = "is the address for"
            flash[:notice] = @target.neo_node_id  + ' was successfully linked as the address for ' + @event.title
          when "relates_to_person"
            rel1 = @event.relates_to_person.new(@target)
            rel2 = @target.relates_to_person.new(@event) 
            rel1.link_desc_en = "is organised or attended by"
            rel2.link_desc_en = "is organising or attending"
            flash[:notice] = @target.first_name  + " " + @target.surname + ' was successfully linked to ' + @event.title
          when "relates_to_organisation"
            rel1 = @event.relates_to_organisation.new(@target)
            rel2 = @target.relates_to_organisation.new(@event) 
            rel1.link_desc_en = "is an event for"
            rel2.link_desc_en = "is organising"
            flash[:notice] = @target.name + ' was successfully linked to ' + @event.title
        end
      end
    end
  end
  
  def new
    @event = Event.value_object.new
  end
  
  private
  def find_event
    @event = Neo4j.load(params[:id])
  end
end