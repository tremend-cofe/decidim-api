# frozen_string_literal: true

module Decidim
  module Proposals
    class UpdateProposalAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "UpdateProposalAttributes"
      description "Attributes for updating a proposal"

      argument :address, GraphQL::Types::String, description: "The physical address for the proposal (if geocoding enabled)", required: false
      argument :body, GraphQL::Types::String, description: "The body content of the proposal", required: true
      argument :latitude, GraphQL::Types::Float, description: "The latitude coordinate for the proposal location", required: false
      argument :longitude, GraphQL::Types::Float, description: "The longitude coordinate for the proposal location", required: false
      argument :title, GraphQL::Types::String, description: "The title of the proposal", required: true
    end
  end
end
