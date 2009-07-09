# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'efb0b5600e8e340eb3584dabecb14b88'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  def linker(params) # link_data will be a hash
    
    @origin = Neo4j.load(params[:origin_id])
    @target = Neo4j.load(params[:target_id])

    # wow this is so crap I can't believe I've written it!!! this needs to be seriously refactored to work with an ontology

    case params[:link_form]["link_category"]
      when "friend"
        rel1 = @origin.personal_rel_to.new(@target)
        rel1.link_category = "friend"
        rel1.link_subcategory = "general friend"
        rel1.link_desc = "is a friend of"
        rel1.link_desc_past = "was a friend of"

        rel2 = @target.personal_rel_to.new(@origin)
        rel2.link_category = "friend"
        rel2.link_subcategory = "general friend"
        rel2.link_desc = "is a friend of"
        rel2.link_desc_past = "was a friend of"
      when "best_friend"
        rel1 = @origin.personal_rel_to.new(@target)
        rel1.link_category = "friend"
        rel1.link_subcategory = "best friend"
        rel1.link_desc = "is the best friend of"
        rel1.link_desc_past = "was the best friend of"

        rel2 = @target.personal_rel_to.new(@origin)
        rel2.link_category = "friend"
        rel2.link_subcategory = "best friend"
        rel2.link_desc = "is the best friend of"
        rel2.link_desc_past = "was the best friend of"
      when "boyfriend"
        rel1 = @origin.personal_rel_to.new(@target)
        rel1.link_category = "friend"
        rel1.link_subcategory = "boyfriend"
        rel1.link_desc = "is the boyfriend of"
        rel1.link_desc_past = "was the boyfriend of"

        rel2 = @target.personal_rel_to.new(@origin)
        rel2.link_category = "friend"
        rel2.link_subcategory = "boyfriend"
        rel2.link_desc = "is the boy/girlfriend of"
        rel2.link_desc_past = "was the boy/girlfriend of"
      when "girlfriend"
        rel1 = @origin.personal_rel_to.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "girlfriend"
        rel1.link_desc = "is a girlfriend of"
        rel1.link_desc_past = "was a girlfriend of"

        rel2 = @target.personal_rel_to.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "girlfriend"
        rel2.link_desc = "is the boy/girlfriend of"
        rel2.link_desc_past = "was the boy/girlfriend of"
      when "enemy"
        rel1 = @origin.personal_rel_to.new(@target)
        rel1.link_category = "enemy"
        rel1.link_subcategory = "enemy"
        rel1.link_desc = "is an enemy of"
        rel1.link_desc_past = "was an enemy of"

        rel2 = @target.personal_rel_to.new(@origin)
        rel2.link_category = "enemy"
        rel2.link_subcategory = "enemy"
        rel2.link_desc = "is an enemy of"
        rel2.link_desc_past = "was an enemy of"
      when "colleague"
        rel1 = @origin.working_rel_to.new(@target)
        rel1.link_category = "colleague"
        rel1.link_subcategory = "general colleague"
        rel1.link_desc = "is a colleague of"
        rel1.link_desc_past = "was a colleague of"

        rel2 = @target.working_rel_to.new(@origin)
        rel2.link_category = "colleague"
        rel2.link_subcategory = "general colleague"
        rel2.link_desc = "is a colleague of"
        rel2.link_desc_past = "was a colleague of"
      when "manager"
        rel1 = @origin.working_rel_to.new(@target)
        rel1.link_category = "colleague"
        rel1.link_subcategory = "manager"
        rel1.link_desc = "is a manager of"
        rel1.link_desc_past = "was a manager of"

        rel2 = @target.working_rel_to.new(@origin)
        rel2.link_category = "colleague"
        rel2.link_subcategory = "subordinate"
        rel2.link_desc = "is a subordinate of"
        rel2.link_desc_past = "was a subordinate of"
      when "subordinate"
        rel1 = @origin.working_rel_to.new(@target)
        rel1.link_category = "colleague"
        rel1.link_subcategory = "subordinate"
        rel1.link_desc = "is a subordinate of"
        rel1.link_desc_past = "was a subordinate of"

        rel2 = @target.working_rel_to.new(@origin)
        rel2.link_category = "colleague"
        rel2.link_subcategory = "manager"
        rel2.link_desc = "is a manager of"
        rel2.link_desc_past = "was a manager of"
      when "husband"
        rel1 = @origin.family_of.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "marriage"
        rel1.link_desc = "is the husband of"
        rel1.link_desc_past = "was the husband of"

        rel2 = @target.family_of.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "marriage"
        rel2.link_desc = "is the wife of"
        rel2.link_desc_past = "was the wife of"
      when "wife"
        rel1 = @origin.family_of.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "marriage"
        rel1.link_desc = "is the wife of"
        rel1.link_desc_past = "was the wife of"

        rel2 = @target.family_of.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "marriage"
        rel2.link_desc = "is the husband of"
        rel2.link_desc_past = "was the husband of"
      when "mother"
        rel1 = @origin.family_of.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "parent"
        rel1.link_desc = "is the mother of"
        rel1.link_desc_past = "was the mother of"

        rel2 = @target.family_of.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "child"
        rel2.link_desc = "is the child of"
        rel2.link_desc_past = "was the child of"
      when "father"
        rel1 = @origin.family_of.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "parent"
        rel1.link_desc = "is the father of"
        rel1.link_desc_past = "was the father of"

        rel2 = @target.family_of.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "child"
        rel2.link_desc = "is the child of"
        rel2.link_desc_past = "was the child of"
      when "brother"
        rel1 = @origin.family_of.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "sibling"
        rel1.link_desc = "is the brother of"
        rel1.link_desc_past = "was the brother of"

        rel2 = @target.family_of.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "sibling"
        rel2.link_desc = "is the sibling of"          # need to add in gender checks
        rel2.link_desc_past = "was the sibling of"
      when "sister"
        rel1 = @origin.family_of.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "sibling"
        rel1.link_desc = "is the sister of"
        rel1.link_desc_past = "was the sister of"

        rel2 = @target.family_of.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "sibling"
        rel2.link_desc = "is the sibling of"
        rel2.link_desc_past = "was the sibling of"
      when "son"
        rel1 = @origin.family_of.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "child"
        rel1.link_desc = "is the son of"
        rel1.link_desc_past = "was the son of"

        rel2 = @target.family_of.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "parent"
        rel2.link_desc = "is the parent of"
        rel2.link_desc_past = "was the parent of"
      when "daughter"
        rel1 = @origin.family_of.new(@target)
        rel1.link_category = "family"
        rel1.link_subcategory = "child"
        rel1.link_desc = "is the daughter of"
        rel1.link_desc_past = "was the daughter of"

        rel2 = @target.family_of.new(@origin)
        rel2.link_category = "family"
        rel2.link_subcategory = "parent"
        rel2.link_desc = "is the parent of"
        rel2.link_desc_past = "was the parent of"
      else # this is just a cheap trick to avoid having to do this properly
        rel1 = @origin.personal_rel_to.new(@target)
        rel1.link_category = "error"
        rel1.link_subcategory = "error"
        rel1.link_desc = "error"
        rel1.link_desc_past = "error"

        rel2 = @target.personal_rel_to.new(@origin)
        rel2.link_category = "error"
        rel2.link_subcategory = "error"
        rel2.link_desc = "error"
        rel2.link_desc_past = "error"
    end
   
    rel1.start_date = params[:start_date]
    rel1.end_date = params[:end_date]
    rel2.start_date = params[:start_date]
    rel2.end_date = params[:end_date]
    
    unless params[:notes] == "<insert notes about this link here>" then
      rel1.notes = params[:notes]
      rel2.notes = params[:notes]
    end

    flash[:notice] = 'nodes were linked successfully'
  end
  
  def unlinker(relationship_ids) #this will be a hash of relationships to delete
    
  end
  
end
