class Event

  include Neo4j::NodeMixin
  
  property :title, :description, :event_type, :start_date, :end_date, :notes
  
  has_n(:person_to_event).to(Person).relationship(Role)
  has_n(:org_to_event).to(Organisation).relationship(Role)
  has_n(:event_to_loc).to(Location).relationship(Role)
  has_n(:event_to_ref).to(Reference).relationship(Role)
  
  index :title, :event_type

  Event::EVENT_TYPES = [
    ["Fundraiser", "Fundraiser"],
    ["Disaster", "Disaster"],
    ["Party", "Party"],
    ["Meeting", "Meeting"],
    ["Conference", "Conference"],
    ["War", "War"]
  ]
  
end