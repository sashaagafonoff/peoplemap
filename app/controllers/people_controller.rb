class PeopleController < ApplicationController
  
  layout 'layout', :except => [:graphml]

  def index
    @people = Person.all.nodes
    @current_node_icon = "/images/icons/male.png"
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
    @object.del
    redirect_to(people_url)
  end
  
  def edit
    @form_explanation = "This form will update the record.  Click <strong>Update</strong> to save it."
    @form_operation = "Update Person"
    if @object.sex == "Female"
      @current_node_icon = "/images/icons/female.png"
    else
      @current_node_icon = "/images/icons/male.png"
    end
  end
  
  def graphml
  end
  
  def show
    @references = Reference.all.nodes.to_a
    @organisations = Organisation.all.nodes.to_a
    @people = Person.all.nodes.to_a
    @locations = Location.all.nodes.to_a
    @events = Event.all.nodes.to_a
    if @object.sex == "Female"
      @current_node_icon = "/images/icons/female.png"
    else
      @current_node_icon = "/images/icons/male.png"
    end
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
    @form_explanation = "This will create a new person record.  Click <strong>Update</strong> to add it to the system."
    @form_operation = "Create Person"
    @current_node_icon = "/images/icons/male.png"
  end
  
  private
  def neo_tx
    Neo4j::Transaction.new
    @object = Neo4j.load_node(params[:id]) if params[:id]
    yield
    Neo4j::Transaction.finish
  end
end