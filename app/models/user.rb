class User
  include Mongoid::Document
  field :username, type: String
  field :password, type: String

  validates_length_of :username, minimum: 5
  validates_length_of :password, minimum: 5
  validates_uniqueness_of :username
  
end
