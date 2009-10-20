class Event

  include Neo4j::NodeMixin
  
  property :title, :description, :event_type, :start_date, :end_date, :notes
  
  has_n(:event_to_person).to(Person).relationship(Role)
  has_n(:event_to_organisation).to(Organisation).relationship(Role)
  has_n(:event_to_event).to(Organisation).relationship(Role)
  has_n(:event_to_location).to(Location).relationship(Role)
  has_n(:event_to_reference).to(Reference).relationship(Role)

  has_n(:person_to_event).from(Person).relationship(Role)
  has_n(:organisation_to_event).from(Organisation).relationship(Role)
  has_n(:location_to_event).from(Location).relationship(Role)
  has_n(:reference_to_event).from(Reference).relationship(Role)

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