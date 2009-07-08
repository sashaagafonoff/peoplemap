class ReferencesController < ApplicationController
  before_filter :find_reference, :only => [:show, :edit, :update, :destroy]
   layout 'layout'
  
  def index
    @references = Reference.find("id:[0 TO 9]").sort_by(:ref_value, :reference_type)
  end
  
  def create
    Neo4j::Transaction.run do
      @reference = Neo4j::Reference.new
      @reference.update(params[:reference])
      flash[:notice] = 'reference was successfully created.'
    end
    redirect_to(references_url)
  end
  
  def update
    Neo4j::Transaction.run do
      @reference.update(params[:reference])
      flash[:notice] = 'reference was successfully updated.'
    end
    redirect_to(@reference)
  end
  
  def destroy
    Neo4j::Transaction.run do
      @reference.delete
      redirect_to(references_url)
    end
  end
  
  def edit
  end
  
  def show
    Neo4j::Transaction.run do
      @reference = Neo4j.load(params[:id])
      
      @references = Reference.find("id:[0 TO 9]").sort_by(:ref_value, :reference_type) # to support list in View
      @organisations = Organisation.find("id:[0 TO 9]").sort_by(:name) # to support list in View
      @people = Person.find("id:[0 TO 9]").sort_by(:surname, :first_name) # to support list in View
      @locations = Location.find("id:[0 TO 9]").sort_by(:street_name, :suburb) # to support list in View
      @events = Location.find("id:[0 TO 9]").sort_by(:title, :event_type) # to support list in View

      if params[:target_id]
        
        @target = Neo4j.load(params[:target_id])
        
        if params[:unlink] then
          @target = Neo4j.load(params[:target_id])
          if (@reference.relationships[@target]) then
            @reference.relationships[@target].delete
          end
          if (@target.relationships[@reference]) then
            @target.relationships[@reference].delete
          end
          flash[:notice] = @target.neo_node_id + ' was successfully unlinked.'
        else
          case params[:link_type]
            when "address_of"
              rel1 = @reference.address_of.new(@target)
              rel2 = @target.address_of.new(@reference) 
              rel1.link_desc_en = "is occurring at"
              rel2.link_desc_en = "is the address for"
              flash[:notice] = @target.neo_node_id  + ' was successfully linked as the address for ' + @reference.title
          end
        end
      end
    end
  end
  
  def new
    Neo4j::Transaction.run do
      @reference = Reference.value_object.new
    end
  end
  
  private
  def find_reference
    Neo4j::Transaction.run do
      @reference = Neo4j.load(params[:id])
    end
  end
end