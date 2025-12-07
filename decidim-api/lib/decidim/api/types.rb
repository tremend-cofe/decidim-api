# frozen_string_literal: true

module Decidim
  module Api
    autoload :QueryType, "decidim/api/query_type"
    autoload :MutationType, "decidim/api/mutation_type"
    autoload :Schema, "decidim/api/schema"
    autoload :RequiredScopes, "decidim/api/required_scopes"
    autoload :GraphqlPermissions, "decidim/api/graphql_permissions"
    autoload :ComponentMutationType, "decidim/api/component_mutation_type"

    module Types
      module Base
        autoload :Argument, "decidim/api/types/base/argument"
        autoload :Enum, "decidim/api/types/base/enum"
        autoload :Field, "decidim/api/types/base/field"
        autoload :Scalar, "decidim/api/types/base/scalar"
        autoload :Union, "decidim/api/types/base/union"
      end

      autoload :BaseInputObject, "decidim/api/types/base_input_object"
      autoload :BaseInterface, "decidim/api/types/base_interface"
      autoload :BaseMutation, "decidim/api/types/base_mutation"
      autoload :BaseObject, "decidim/api/types/base_object"
    end
  end
end
