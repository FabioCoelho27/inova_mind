class QuoteSerializer < ActiveModel::Serializer
  attributes :quote
  attributes :author
  attributes :author_about
  attributes :tags
end
