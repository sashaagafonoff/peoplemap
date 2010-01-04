class User

  include Neo4j::NodeMixin

  property :username, :first_name, :surname, :password, :date_created, :password

  has_n(:user_to_person).to(Person).relationship(Role)

  has_n(:user_to_organisation).to(Organisation).relationship(Role)
  has_n(:user_to_event).to(Event).relationship(Role)
  has_n(:user_to_location).to(Location).relationship(Role)
  has_n(:user_to_reference).to(Reference).relationship(Role)

  has_n(:organisation_to_user).from(Organisation).relationship(Role)
  has_n(:event_to_user).from(Event).relationship(Role)
  has_n(:location_to_user).from(Location).relationship(Role)
  has_n(:reference_to_user).from(Reference).relationship(Role)


  index :username, :surname, :first_name

end