class EventsController < ApplicationController
  before_filter :find_event, :only => [:show, :edit, :update, :destroy]
   layout 'layout'
  
  def index
    @events = Event.find("id:[0 TO 9]").sort_by(:title, :event_type)
  end
  
  def create
    Neo4j::Transaction.run do
      @event = Neo4j::Event.new
      @event.update(params[:event])
      flash[:notice] = 'event was successfully created.'
    end
    redirect_to(events_url)
  end
  
  def update
    Neo4j::Transaction.run do
      @event.update(params[:event])
      flash[:notice] = 'event was successfully updated.'
    end
    redirect_to(@event)
  end
  
  def destroy
    Neo4j::Transaction.run do
      @event.delete
      redirect_to(events_url)
    end
  end
  
  def edit
  end
  
  def show
    Neo4j::Transaction.run do
      @event = Neo4j.load(params[:id])
      
      @references = Reference.find("id:[0 TO 9]").sort_by(:ref_value, :reference_type) # to support list in View
      @organisations = Organisation.find("id:[0 TO 9]").sort_by(:name) # to support list in View
      @people = Person.find("id:[0 TO 9]").sort_by(:surname, :first_name) # to support list in View
      @locations = Location.find("id:[0 TO 9]").sort_by(:street_name, :suburb) # to support list in View
      @events = Location.find("id:[0 TO 9]").sort_by(:title, :event_type) # to support list in View

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
  end
  
  def new
    Neo4j::Transaction.run do
      @event = Event.value_object.new
    end
  end
  
  private
  def find_event
    Neo4j::Transaction.run do
      @event = Neo4j.load(params[:id])
    end
  end
end