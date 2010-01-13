class ReferencesController < ApplicationController
  
  layout 'layout', :except => [:graphml]
  
  def index
    @references = Reference.all.nodes
    @current_node_icon = "/images/icons/note.png"
  end
  
  def create
    @object = Reference.new
    @object.update(params[:reference])
    flash[:notice] = 'Reference was successfully created.'
    redirect_to(@object)
  end
  
  def update
    @object.update(params[:reference])
    flash[:notice] = 'Reference was successfully updated.'
    redirect_to(@object)
  end
  
  def destroy
    @object.delete
    redirect_to(references_url)
  end
  
  def edit
    @form_explanation = "This form will update the record.  Click <strong>Update</strong> to save it."
    @form_operation = "Update Reference"
    @current_node_icon = "/images/icons/note.png"
  end
  
  def show
    @people = Person.all.nodes
    @organisations = Organisation.all.nodes
    @references = Reference.all.nodes
    @locations = Location.all.nodes
    @events = Event.all.nodes
    @current_node_icon = "/images/icons/note.png"
  end

  def link
    linker(params)
    redirect_to(@object)
    flash[:notice] = @object.ref_value + " was linked to node " + @target.neo_node_id.to_s
  end
  
  def unlink
    unlinker(params)
    redirect_to(@object)
    flash[:notice] = @object.ref_value + " was unlinked from " + @target.neo_node_id.to_s
  end
  
  def new
    @object = Reference.value_object.new
    @form_explanation = "This will create a new reference. Click <strong>Update</strong> to add it to the system."
    @form_operation = "Create Reference"
    @current_node_icon = "/images/icons/note.png"
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