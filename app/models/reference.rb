class Reference
  
  include Neo4j::NodeMixin
  
  property :reference_type, :ref_value, :notes
  
  has_n(:reference_to_person).to(Person).relationship(Role)
  has_n(:reference_to_organisation).to(Organisation).relationship(Role)
  has_n(:reference_to_location).to(Location).relationship(Role)
  has_n(:reference_to_event).to(Event).relationship(Role)
  has_n(:reference_to_reference).to(Reference).relationship(Role)

  has_n(:person_to_reference).from(Person).relationship(Role)
  has_n(:organisation_to_reference).from(Organisation).relationship(Role)
  has_n(:location_to_reference).from(Location).relationship(Role)
  has_n(:event_to_reference).from(Event).relationship(Role)

  index :ref_value, :reference_type

  Reference::REFERENCE_TYPES = [
    ["Email Address","email"],
    ["Home Phone Number","home_phone"],
    ["Work Phone Number","work_phone"],
    ["Mobile Phone Number","mobile_phone"],
    ["Profile Photo","profile_photo"],
    ["Photograph","photo"],
    ["Website","web_url"],
    ["Related Web Page","related_url"],
    ["File Attachment","file_attachment"],
  ]
  
end