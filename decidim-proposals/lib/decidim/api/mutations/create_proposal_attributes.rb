# frozen_string_literal: true

module Decidim
  module Proposals
    class CreateProposalAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "CreateProposalAttributes"
      description "Attributes for creating a proposal"

      argument :title, GraphQL::Types::String, description: "The title of the proposal", required: true
      argument :body, GraphQL::Types::String, description: "The body content of the proposal", required: true
      argument :address, GraphQL::Types::String, description: "Physical address for the proposal", required: false
      argument :latitude, GraphQL::Types::Float, description: "Latitude coordinate", required: false
      argument :longitude, GraphQL::Types::Float, description: "Longitude coordinate", required: false
      argument :taxonomy_ids, [GraphQL::Types::ID], description: "Array of taxonomy IDs", required: false
    end
  end
end
