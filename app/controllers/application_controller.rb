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

    # wow this is so crap I can't believe I've written it!!! this needs to be seriously refactored to work with an ontology - now it's done, it probably would have been less work to write it properly #@!$$#@!!!!

    case params[:link_form]["link_category"]

      # personal relationships (person to person)

      #Person::TO_PERSON_LINK_CATEGORIES = [
      #  ["Friend", "friend"],
      #  ["Best Friend", "best_friend"],
      #  ["Enemy", "enemy"],
      #  ["Colleague", "colleague"],
      #  ["Manager", "manager"],
      #  ["Subordinate", "subordinate"],
      #  ["Husband", "husband"],
      #  ["Wife", "wife"],
      #  ["Mother", "mother"],
      #  ["Father", "father"],
      #  ["Brother", "brother"],
      #  ["Sister", "sister"],
      #  ["Son", "son"],
      #  ["Daughter", "daughter"],
      #  ["Boyfriend", "boyfriend"],
      #  ["Girlfriend", "girlfriend"]
      #]
      
      when "friend"
        rel1 = @origin.personal_rel_to.new(@target)         # it may be simpler just to provide a set relation type for each entity to entity relation and then rely on properties to support filtering - I'm still thinking this one through
        rel1.link_category = "friend"                       # category is a screen friendly name for the relation type
        rel1.link_subcategory = "general friend"            # subcategory is a subcategory for finer-grained filtering- ideally this type of data is managed from an ontology and is n-levels deep
        rel1.link_desc = "is a friend of"
        rel1.link_desc_past = "was a friend of"

        rel2 = @target.personal_rel_to.new(@origin)
        rel2.link_category = "friend"
        rel2.link_subcategory = "general friend"
        rel2.link_desc = "is a friend of"                   # reverse link description for reverse path (in some cases these are quite different eg mother/daughter, etc)
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

      # person to person working relationships

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

      # person to person family relationships

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

      # person to organisation

      #  Person::TO_ORG_LINK_CATEGORIES = [
      #    ["Works For", "works"],
      #    ["Member Of", "member"],
      #    ["Volunteer For", "volunteer"],
      #    ["Banned From", "banned"],
      #    ["Supports", "supports"]
      #]

      when "works"
        rel1 = @origin.org_rel_with.new(@target)
        rel1.link_category = "organisational"
        rel1.link_subcategory = "employee"
        rel1.link_desc = "works for"
        rel1.link_desc_past = "worked for"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = "organisational"
        rel2.link_subcategory = "employee"
        rel2.link_desc = "employs"
        rel2.link_desc_past = "employed"

      when "volunteer"
        rel1 = @origin.org_rel_with.new(@target)
        rel1.link_category = "organisational"
        rel1.link_subcategory = "volunteer"
        rel1.link_desc = "is a volunteer for"
        rel1.link_desc_past = "was a volunteer for"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = "organisational"
        rel2.link_subcategory = "volunteer"
        rel2.link_desc = "uses the voluntary services of"
        rel2.link_desc_past = "used the voluntary services of"

      when "member"
        rel1 = @origin.org_rel_with.new(@target)
        rel1.link_category = "organisational"
        rel1.link_subcategory = "member"
        rel1.link_desc = "is a member of"
        rel1.link_desc_past = "was a member of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = "organisational"
        rel2.link_subcategory = "member"
        rel2.link_desc = "has as a member"
        rel2.link_desc_past = "had as a member"

      when "banned"
        rel1 = @origin.org_rel_with.new(@target)
        rel1.link_category = "organisational"
        rel1.link_subcategory = "banned"
        rel1.link_desc = "is banned from"
        rel1.link_desc_past = "was banned from"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = "organisational"
        rel2.link_subcategory = "banned"
        rel2.link_desc = "has a ban on"
        rel2.link_desc_past = "banned"

      when "supports"
        rel1 = @origin.org_rel_with.new(@target)
        rel1.link_category = "organisational"
        rel1.link_subcategory = "supporter"
        rel1.link_desc = "is the supporter of"
        rel1.link_desc_past = "was the supporter of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = "organisational"
        rel2.link_subcategory = "supporter"
        rel2.link_desc = "is supported by"
        rel2.link_desc_past = "was supported by"

      # person to location

      #  Person::TO_LOC_LINK_CATEGORIES = [
      #    ["Home Address", "home_address"],
      #    ["Work Address", "work_address"]
      #]
      
      when "home_address"
        rel1 = @origin.address_of.new(@target)
        rel1.link_category = "address"
        rel1.link_subcategory = "home address"
        rel1.link_desc = "is the home address of"
        rel1.link_desc_past = "was the home address of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = "address"
        rel2.link_subcategory = "home address"
        rel2.link_desc = "is the home address for"
        rel2.link_desc_past = "was the home address for"

      when "work_address"
        rel1 = @origin.address_of.new(@target)
        rel1.link_category = "address"
        rel1.link_subcategory = "work address"
        rel1.link_desc = "is the work address of"
        rel1.link_desc_past = "was the work address of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = "address"
        rel2.link_subcategory = "work address"
        rel2.link_desc = "is the work address for"
        rel2.link_desc_past = "was the work address for"

      # person to event

      #  Person::TO_EVENT_LINK_CATEGORIES = [
      #    ["Attended", "attended"],
      #    ["Organised", "organised"],
      #    ["Caused", "caused"],
      #    ["Participated In", "participated"],
      #    ["Supported", "supported"],
      #    ["Objected To", "objected"]
      #    ]

      when "attended"
        rel1 = @origin.relates_to_person.new(@target)
        rel1.link_category = "event"
        rel1.link_subcategory = "attendance"
        rel1.link_desc = "is attending"
        rel1.link_desc_past = "attended"

        rel2 = @target.relates_to_person.new(@origin)
        rel2.link_category = "event"
        rel2.link_subcategory = "attendance"
        rel2.link_desc = "will be attended by"
        rel2.link_desc_past = "was attended by"

      when "organised"
        rel1 = @origin.relates_to_person.new(@target)
        rel1.link_category = "event"
        rel1.link_subcategory = "organised"
        rel1.link_desc = "is the organiser of"
        rel1.link_desc_past = "was the organiser of"

        rel2 = @target.relates_to_person.new(@origin)
        rel2.link_category = "event"
        rel2.link_subcategory = "organised"
        rel2.link_desc = "is being organised by"
        rel2.link_desc_past = "was organised by"

      when "caused"
        rel1 = @origin.relates_to_person.new(@target)
        rel1.link_category = "event"
        rel1.link_subcategory = "caused"
        rel1.link_desc = "is the cause of"             # probably redundant
        rel1.link_desc_past = "was the caused of"

        rel2 = @target.relates_to_person.new(@origin)
        rel2.link_category = "event"
        rel2.link_subcategory = "caused"
        rel2.link_desc = "is caused by"                 # probably redundant
        rel2.link_desc_past = "was caused by"

      when "participated"
        rel1 = @origin.relates_to_person.new(@target)
        rel1.link_category = "event"
        rel1.link_subcategory = "participant"
        rel1.link_desc = "is a participant in"
        rel1.link_desc_past = "was a participant in"

        rel2 = @target.relates_to_person.new(@origin)
        rel2.link_category = "event"
        rel2.link_subcategory = "participant"
        rel2.link_desc = "is being participated in by"
        rel2.link_desc_past = "was participated in by"

      when "supported"
        rel1 = @origin.relates_to_person.new(@target)
        rel1.link_category = "event"
        rel1.link_subcategory = "supporter"
        rel1.link_desc = "is the supporter of"
        rel1.link_desc_past = "was the supporter of"

        rel2 = @target.relates_to_person.new(@origin)
        rel2.link_category = "event"
        rel2.link_subcategory = "supporter"
        rel2.link_desc = "is supported by"
        rel2.link_desc_past = "was supported by"

      when "objected"
        rel1 = @origin.relates_to_person.new(@target)
        rel1.link_category = "event"
        rel1.link_subcategory = "objection"
        rel1.link_desc = "objects to"
        rel1.link_desc_past = "objected to"

        rel2 = @target.relates_to_person.new(@origin)
        rel2.link_category = "event"
        rel2.link_subcategory = "objection"
        rel2.link_desc = "is objected to by"
        rel2.link_desc_past = "was objected to by"

      # person to reference

      #Person::TO_REF_LINK_CATEGORIES = [
      #  ["Email Address", "email"],
      #  ["Home Phone", "home_phone"],
      #  ["Work Phone", "work_phone"],
      #  ["Mobile Phone", "mobile"],
      #  ["Website URL", "website"],
      #  ["Facebook URL", "facebook"],
      #  ["LinkedIn URL", "linkedin"],
      #  ["Twitter URL", "twitter"],
      #  ["Photo", "photo"],                 # obviously need to support this properly
      #  ["File Attachment", "attachment"]   # this too
      #  ]

      when "email"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "home_phone"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "work_phone"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "mobile"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "website"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "facebook"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "linkedin"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "twitter"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "photo"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"

      when "attachment"
        rel1 = @origin.reference_to_person.new(@target)
        rel1.link_category = ""
        rel1.link_subcategory = ""
        rel1.link_desc = "is the  of"
        rel1.link_desc_past = "was the  of"

        rel2 = @target.org_rel_with.new(@origin)
        rel2.link_category = ""
        rel2.link_subcategory = ""
        rel2.link_desc = "is  for"
        rel2.link_desc_past = "was  for"


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
