class OrganisationsController < ApplicationController
  before_filter :find_organisation, :only => [:show, :edit, :update, :destroy]
  layout 'layout'
  
  def index
    @organisations = Organisation.find("id:[0 TO 9]").sort_by(:name)
  end
  
  def create
    Neo4j::Transaction.run do
      @organisation = Neo4j::Organisation.new
      @organisation.update(params[:organisation])
      flash[:notice] = 'Organisation was successfully created.'
    end
    redirect_to(organisations_url)
  end
  
  def update
    Neo4j::Transaction.run do
      @organisation.update(params[:organisation])
      flash[:notice] = 'Organisation was successfully updated.'
    end
    redirect_to(@organisation)
  end
  
  def destroy
    Neo4j::Transaction.run do
      @organisation.delete
      redirect_to(organisations_url)
    end
  end
  
  def edit
  end
  
  def show
    Neo4j::Transaction.run do
      @organisation = Neo4j.load(params[:id])

      @references = Reference.find("id:[0 TO 9]").sort_by(:ref_value, :reference_type) # to support list in View
      @organisations = Organisation.find("id:[0 TO 9]").sort_by(:name) # to support list in View
      @people = Person.find("id:[0 TO 9]").sort_by(:surname, :first_name) # to support list in View
      @locations = Location.find("id:[0 TO 9]").sort_by(:street_name, :suburb) # to support list in View
      @events = Location.find("id:[0 TO 9]").sort_by(:title, :event_type) # to support list in View

      if params[:target_id]
        
        @target = Neo4j.load(params[:target_id])
        
        if params[:unlink] then
          @target = Neo4j.load(params[:target_id])
          if (@organisation.relationships[@target]) then
            @organisation.relationships[@target].delete
          end
          if (@target.relationships[@organisation]) then
            @target.relationships[@organisation].delete
          end
          flash[:notice] = @target.neo_node_id  + ' was successfully unlinked.'
        else
          case params[:link_type]
            when "partner"
              rel1 = @organisation.partner_of.new(@target)
              rel2 = @target.partner_of.new(@organisation) 
              rel1.link_desc_en = "is a partner with"
              rel2.link_desc_en = "is a partner with"
              flash[:notice] = @target.name + ' was successfully linked as a partner.'
            when "competitor"
              rel1 = @organisation.competes_with.new(@target)
              rel2 = @target.competes_with.new(@organisation) 
              rel1.link_desc_en = "competes with"
              rel2.link_desc_en = "competes with"
              flash[:notice] = @target.name + ' was successfully linked as an enemy.'
          end
        end
      end
    end
  end
  
  def new
    Neo4j::Transaction.run do
      @organisation = Organisation.value_object.new
    end
  end
     
  private
  def find_organisation
    Neo4j::Transaction.run do
      @organisation = Neo4j.load(params[:id])
    end
  end
end