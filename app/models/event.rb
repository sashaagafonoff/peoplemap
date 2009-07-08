class Role
  include Neo4j::RelationshipMixin
  property :link_desc, :link_desc_past, :link_category, :link_subcategory, :start_date, :end_date, :notes, :author, :reliability
end

class Event

  Event::EVENT_TYPES = [
    ["Fundraiser", "Fundraiser"],
    ["Disaster", "Disaster"],
    ["Party", "Party"],
    ["Meeting", "Meeting"],
    ["Conference", "Conference"],
    ["War", "War"]
  ]
  
  include Neo4j::NodeMixin
  property :title, :description, :event_type, :start_date, :end_date, :notes
  has_n(:relates_to_person).to(Person).relationship(Role)
  has_n(:relates_to_organisation).to(Organisation).relationship(Role)
  has_n(:address_of).to(Location).relationship(Role)
  has_n(:reference_to_event).to(Reference).relationship(Role)
  index :title, :event_type
end