class Role
  include Neo4j::RelationshipMixin
  property :link_desc, :link_desc_past, :link_category, :link_subcategory, :start_date, :end_date, :notes, :author, :reliability
end

class Person
  
  Person::LINK_CATEGORIES = [
    ["Friend", "Friend"],
    ["Acquaintance", "Acquaintance"],
    ["Enemy", "Enemy"],
    ["Fan", "Fan"],
    ["Rival", "Rival"]
  ]

  Person::TITLE_TYPES = [
    ["Mr", "Mr"],
    ["Mrs", "Mrs"],
    ["Ms", "Ms"],
    ["Miss", "Miss"],
    ["Master", "Master"]
  ]
  
  Person::SEXES = [
    ["Male","Male"],
    ["Female","Female"]
  ]
  
  include Neo4j::NodeMixin
  property :title, :first_name, :middle_names, :surname, :maternal_name, :date_of_birth, :classification, :sex, :notes
  has_n(:family_of).to(Person).relationship(Role)
  has_n(:personal_rel_to).to(Person).relationship(Role)
  has_n(:working_rel_to).to(Person).relationship(Role)
  has_n(:org_rel_with).to(Organisation).relationship(Role)
  has_n(:relates_to_person).to(Event).relationship(Role)
  has_n(:address_of).to(Location).relationship(Role)
  has_n(:reference_to_person).to(Reference).relationship(Role)
  index :surname, :first_name, :classification
end