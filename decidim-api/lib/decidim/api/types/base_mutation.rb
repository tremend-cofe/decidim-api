# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseMutation < GraphQL::Schema::RelayClassicMutation
        include Decidim::Api::GraphqlPermissions

        object_class BaseObject
        field_class Decidim::Api::Types::Base::Field
        input_object_class BaseInputObject

        required_scopes "api:read", "api:write"
      end
    end
  end
end
