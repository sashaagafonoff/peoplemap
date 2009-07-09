class PeopleController < ApplicationController
  
  before_filter :find_person, :only => [:show, :edit, :update, :destroy]
  layout 'layout'
  
  def index
    @people = Person.find("id:[0 TO 9]").sort_by(:first_name)
  end
  
  def create
    Neo4j::Transaction.run do
      @person = Neo4j::Person.new
      @person.update(params[:person])
      flash[:notice] = 'Person was successfully created.'
    end
    redirect_to(people_url)
  end
  
  def update
    Neo4j::Transaction.run do
      @person.update(params[:person])
      flash[:notice] = 'Person was successfully updated.'
    end
    redirect_to(@person)
  end
  
  def destroy
    Neo4j::Transaction.run do
      @person.delete
      redirect_to(people_url)
    end
  end
  
  def edit
  end
  
  def show
    Neo4j::Transaction.run do
      @person = Neo4j.load(params[:id])
      
      @references = Reference.find("id:[0 TO 9]").sort_by(:ref_value, :reference_type) # to support list in View
      @organisations = Organisation.find("id:[0 TO 9]").sort_by(:name) # to support list in View
      @people = Person.find("id:[0 TO 9]").sort_by(:surname, :first_name) # to support list in View
      @locations = Location.find("id:[0 TO 9]").sort_by(:street_name, :suburb) # to support list in View
      @events = Event.find("id:[0 TO 9]").sort_by(:title, :event_type) # to support list in View

      if params[:target_id]
        
        @target = Neo4j.load(params[:target_id])
        
        if params[:unlink] then # this needs to be improved
          @target = Neo4j.load(params[:target_id])
          if (@person.relationships[@target]) then
            @person.relationships[@target].delete
          end
          if (@target.relationships[@person]) then
            @target.relationships[@person].delete
          end
          flash[:notice] = @target.neo_node_id.to_s + ' was successfully unlinked.'
        else
          linker(params)
        end
      end
    end
  end
  
  def new
    Neo4j::Transaction.run do
      @person = Person.value_object.new
    end
  end
  
  private
  def find_person
    Neo4j::Transaction.run do
      @person = Neo4j.load(params[:id])
    end
  end
end