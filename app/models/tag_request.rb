class TagRequest
  include Mongoid::Document
  field :tag, type: String
  field :date, type: DateTime

  validates_uniqueness_of :tag
  
end
