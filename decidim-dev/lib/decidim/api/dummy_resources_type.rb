# frozen_string_literal: true

module Decidim
  module Dev
    class DummyResourcesType < Decidim::Core::ComponentType
      graphql_name "Dummies"
      description "A dummies component of a participatory space."

      field :dummy_resource, type: Decidim::Dev::DummyResourceType, description: "Finds one dummy", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the proposal", required: true
      end
      field :dummy_resources, type: Decidim::Dev::DummyResourceType.connection_type, description: "List all dummies", connection: true, null: true do
        # argument :filter, Decidim::Dev::DummyResourceInputFilter, "Provides several methods to filter the results", required: false
        # argument :order, Decidim::Dev::DummyResourceInputSort, "Provides several methods to order the results", required: false
      end
      def dummies(filter: {}, order: {})
        Decidim::Dev::DummyResource.all
      end

      def dummy(id:)
        Decidim::Dev::DummyResource.find(id)
      end
    end
  end
end
