class Organisation
  
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
  
  include Neo4j::NodeMixin
  property :name, :sector, :industry, :notes
  has_n(:person_to_org).from(Person).relationship(Role)
  has_n(:org_to_org).to(Organisation).relationship(Role)
  index :name
end