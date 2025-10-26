# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root query type of the whole API.
    class QueryType < Decidim::Api::Types::BaseObject
      description "The root query of this schema"

      field :component, Decidim::Core::ComponentInterface, null: true do
        description "Lists the components this space contains."
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the component to be found"
      end
      field :decidim, Core::DecidimType, "Decidim's framework properties.", null: true
      field :organization, Core::OrganizationType, "The current organization", null: true
      field :session, Core::SessionType, description: "Return's information about the logged in user", null: true
      field :user,
            type: Core::AuthorInterface, null: true,
            description: "A participant (user or group) in the current organization" do
        argument :id, GraphQL::Types::ID, "The ID of the participant", required: false
        argument :nickname, GraphQL::Types::String, "The @nickname of the participant", required: false
      end
      field :users,
            type: [Core::AuthorInterface], null: true,
            description: "The participants (users or groups) for the current organization" do
        argument :filter, Decidim::Core::UserEntityInputFilter, "Provides several methods to filter the results", required: false
        argument :order, Decidim::Core::UserEntityInputSort, "Provides several methods to order the results", required: false
      end

      def component(id: {})
        component = Decidim::Component.published.find_by(id:)
        component&.organization == context[:current_organization] ? component : nil
      end

      def session
        context[:current_user]
      end

      def decidim
        Decidim
      end

      def organization
        context[:current_organization]
      end

      def user(id: nil, nickname: nil)
        Core::UserEntityFinder.new.call(object, { id:, nickname: }, context)
      end

      def users(filter: {}, order: {})
        Core::UserEntityList.new.call(object, { filter:, order: }, context)
      end
    end
  end
end
