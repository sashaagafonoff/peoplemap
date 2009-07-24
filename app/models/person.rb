class Person

    include Neo4j::NodeMixin
    property :title, :first_name, :middle_names, :surname, :maternal_name, :date_of_birth, :classification, :sex, :notes
    
    has_n(:person_to_person).to(Person).relationship(Role)
    has_n(:person_to_org).to(Organisation).relationship(Role)
    has_n(:event_to_person).to(Event).relationship(Role)
    has_n(:loc_to_person).to(Location).relationship(Role)
    has_n(:ref_to_person).to(Reference).relationship(Role)
    
    index :surname, :first_name, :classification

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
    ["Child", "child"],
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
  
end