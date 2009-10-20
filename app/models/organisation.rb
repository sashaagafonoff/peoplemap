class Organisation
  
  include Neo4j::NodeMixin
  
  property :name, :sector, :industry, :notes
  
  has_n(:organisation_to_person).to(Person).relationship(Role)
  has_n(:organisation_to_organisation).to(Organisation).relationship(Role)
  has_n(:organisation_to_event).to(Event).relationship(Role)
  has_n(:organisation_to_location).to(Location).relationship(Role)
  has_n(:organisation_to_reference).to(Reference).relationship(Role)

  has_n(:person_to_organisation).from(Person).relationship(Role)
  has_n(:event_to_organisation).from(Event).relationship(Role)
  has_n(:location_to_organisation).from(Location).relationship(Role)
  has_n(:reference_to_organisation).from(Reference).relationship(Role)

  index :name

  Organisation::SECTOR_TYPES = [
    ["Government","Government"],
    ["Private Sector","Private Sector"],
    ["Education","Education"],
    ["Non-Profit","Non-Profit"],
    ["Criminal","Criminal"],
    ["Other","Other"]
  ]

  Organisation::INDUSTRY_TYPES = [
    ["Aeronautics","Aeronautics"],
    ["Acrobatics","Acrobatics"],
    ["Government","Government"],
    ["Mining","Mining"],
    ["Terrorism","Terrorism"],
    ["etc","etc"]
  ]
  
end