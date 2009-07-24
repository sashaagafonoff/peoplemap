class Reference
  
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
  
  include Neo4j::NodeMixin
  property :reference_type, :ref_value, :notes
  has_n(:reference_to_person).to(Person).relationship(Role)
  has_n(:org_rel_with).to(Organisation).relationship(Role)
  has_n(:reference_to_loc).to(Location).relationship(Role)
  has_n(:reference_to_event).to(Event).relationship(Role)
  index :ref_value, :reference_type
end