# frozen_string_literal: true

module Decidim
  module Api
    module Types
      module Base
        class Mutation < GraphQL::Schema::RelayClassicMutation
          include Decidim::Api::GraphqlPermissions

          object_class BaseObject
          field_class Decidim::Api::Types::Base::Field
          input_object_class Decidim::Api::Types::Base::InputObject

          required_scopes "api:read", "api:write"
        end
      end
    end
  end
end
