class Role
  include Neo4j::RelationshipMixin
  property :name, :start_date, :end_date, :notes, :author, :reliability

end