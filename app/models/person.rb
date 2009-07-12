class Role
  include Neo4j::RelationshipMixin
  property :link_desc, :link_desc_past, :link_category, :link_subcategory, :start_date, :end_date, :notes, :author, :reliability
end

class Person

  # horrible way to do this, I know, but it will work for the time being...

  Person::TO_PERSON_LINK_CATEGORIES = [
    ["Friend", "friend"],
    ["Best Friend", "best_friend"],
    ["Enemy", "enemy"],
    ["Colleague", "colleague"],
    ["Manager", "manager"],
    ["Subordinate", "subordinate"],
    ["Husband", "husband"],
    ["Wife", "wife"],
    ["Mother", "mother"],
    ["Father", "father"],
    ["Brother", "brother"],
    ["Sister", "sister"],
    ["Son", "son"],
    ["Daughter", "daughter"],
    ["Boyfriend", "boyfriend"],
    ["Girlfriend", "girlfriend"]
  ]

  Person::TO_ORG_LINK_CATEGORIES = [
    ["Works For", "works"],
    ["Member Of", "member"],
    ["Volunteer For", "volunteer"],
    ["Banned From", "banned"],
    ["Supports", "supports"]
]

  Person::TO_LOC_LINK_CATEGORIES = [
    ["Home Address", "home_address"],
    ["Work Address", "work_address"]
]

  Person::TO_EVENT_LINK_CATEGORIES = [
    ["Attended", "attended"],
    ["Organised", "organised"],
    ["Caused", "caused"],
    ["Participated In", "participated"],
    ["Supported", "supported"],
    ["Objected To", "objected"]
]

  Person::TO_REF_LINK_CATEGORIES = [
    ["Email Address", "email"],
    ["Home Phone", "home_phone"],
    ["Work Phone", "work_phone"],
    ["Mobile Phone", "mobile"],
    ["Website URL", "website"],
    ["Facebook URL", "facebook"],
    ["LinkedIn URL", "linkedin"],
    ["Twitter URL", "twitter"],
    ["Photo", "photo"],                 # obviously need to support this properly
    ["File Attachment", "attachment"]   # this too
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