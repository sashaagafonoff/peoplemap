class PeopleController < ApplicationController
  
  around_filter :neo_tx
  layout 'layout', :except => [:graphml]
  
  def index
    @people = Person.all.nodes
  end
  
  def create
    @object = Person.new
    @object.update(params[:person])
    flash[:notice] = 'Person was successfully created.'
    redirect_to(@object)
  end
  
  def update
    @object.update(params[:person])
    flash[:notice] = 'Person was successfully updated.'
    redirect_to(@object)
  end
  
  def destroy
    @object.delete
    redirect_to(people_url)
  end
  
  def edit
  end
  
  def graphml
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
    flash[:notice] = [@object.first_name, @object.surname].join(" ") + " was linked to " + get_display_name(@target)
  end
  
  def unlink
    unlinker(params)
    redirect_to(@object)
    flash[:notice] = [@object.first_name, @object.surname].join(" ") + " was unlinked from " + get_display_name(@target)
  end
  
  def new
    @object = Person.value_object.new
  end
  
  private
  def neo_tx
    Neo4j::Transaction.new
    @object = Neo4j.load(params[:id]) if params[:id]
    yield
    Neo4j::Transaction.finish
  end
end