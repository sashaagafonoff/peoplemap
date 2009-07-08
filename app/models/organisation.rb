class Role
  include Neo4j::RelationshipMixin
  property :link_desc, :link_desc_past, :link_category, :link_subcategory, :start_date, :end_date, :notes, :author, :reliability
end

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
  has_n(:org_rel_with).to(Person).relationship(Role)
  has_n(:partner_of).to(Organisation).relationship(Role)
  has_n(:competes_with).to(Organisation).relationship(Role)
  has_n(:relates_to_organisation).to(Event).relationship(Role)
  has_n(:address_of).to(Location).relationship(Role)
  has_n(:reference_to_org).to(Reference).relationship(Role)
  index :name
end