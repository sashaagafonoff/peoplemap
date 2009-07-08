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
  
  def linker(link_data) # link_data will be a hash
    
    @origin = link_data[:origin]
    @target = link_data[:target]

    case link_data[:link_category]
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
    end
   
    rel1.start_date = link_data[:start_date]
    rel1.end_date = link_data[:end_date]
    rel2.start_date = link_data[:start_date]
    rel2.end_date = link_data[:end_date]
    
    rel1.notes = link_data[:notes]    

    flash[:notice] = 'nodes were linked successfully'
  end
  
  def unlinker(relationship_ids) #this will be a hash of relationships to delete
    
  end
  
end
