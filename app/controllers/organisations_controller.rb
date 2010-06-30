class OrganisationsController < ApplicationController
  
  layout 'layout', :except => [:graphml]
  
  def index
    @organisations = Organisation.all.nodes
    @current_node_icon = "/images/icons/organisation.png"
  end
  
  def create
    @object = Organisation.new
    @object.update(params[:organisation])
    flash[:notice] = 'Organisation was successfully created.'
    redirect_to(@object)
  end
  
  def update
    @object.update(params[:organisation])
    flash[:notice] = 'Organisation was successfully updated.'
    redirect_to(@object)
  end
  
  def destroy
    @object.del
    redirect_to(organisations_url)
  end
  
  def edit
    @form_explanation = "This form will update the record.  Click <strong>Update</strong> to save it."
    @form_operation = "Update Organisation"
    @current_node_icon = "/images/icons/organisation.png"
  end
  
  def show
    @references = Reference.all.nodes
    @organisations = Organisation.all.nodes
    @people = Person.all.nodes
    @locations = Location.all.nodes
    @events = Event.all.nodes
    @current_node_icon = "/images/icons/organisation.png"
  end

  def link
    linker(params)
    redirect_to(@object)
    flash[:notice] = @object.name + " was linked to node " + @target.neo_id.to_s
  end
  
  def unlink
    unlinker(params)
    redirect_to(@object)
    flash[:notice] = @object.name + " was unlinked from " + @target.neo_id.to_s
  end
  
  def new
    @object = Organisation.value_object.new
    @form_explanation = "This will create a new organisation record.  Click <strong>Update</strong> to add it to the system."
    @form_operation = "Create Organisation"
    @current_node_icon = "/images/icons/organisation.png"
  end
  
  def graphml
  end

  private
  def neo_tx
    Neo4j::Transaction.new
    @object = Neo4j.load_node(params[:id]) if params[:id]
    yield
    Neo4j::Transaction.finish
  end

end