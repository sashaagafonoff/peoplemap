class Reference
  
  include Neo4j::NodeMixin
  
  property :reference_type, :ref_value, :notes
  
  has_n(:person_to_ref).from(Person).relationship(Role)
  has_n(:org_to_ref).from(Organisation).relationship(Role)
  has_n(:loc_to_ref).from(Location).relationship(Role)
  has_n(:event_to_ref).from(Event).relationship(Role)
  has_n(:ref_to_ref).to(Reference).relationship(Role)
  
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