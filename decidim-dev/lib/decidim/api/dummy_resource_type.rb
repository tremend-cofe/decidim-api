# frozen_string_literal: true

module Decidim
  module Dev
    class DummyResourceType < Decidim::Api::Types::BaseObject
      description "A dummy resource"

      implements Decidim::Core::AmendableInterface
      implements Decidim::Core::AmendableEntityInterface

      field :id, GraphQL::Types::ID, "The id of the dummy resource", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this dummy resource", null: true
    end
  end
end
