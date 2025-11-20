# frozen_string_literal: true

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    class Schema < GraphQL::Schema
      mutation(MutationType)
      query(QueryType)

      default_max_page_size Decidim::Api.schema_max_per_page
      max_depth Decidim::Api.schema_max_depth
      max_complexity Decidim::Api.schema_max_complexity

      orphan_types(Api.orphan_types)

      def self.unauthorized_object(error)
        # Add a top-level error to the response instead of returning nil:
        Rails.logger.warn("[API] - An object of type #{error.type.graphql_name} was hidden due to permissions")
        nil
      end

      def self.unauthorized_field(error)
        # Add a top-level error to the response instead of returning nil:
        Rails.logger.warn("[API] - The field #{error.field.graphql_name} on an object of type #{error.type.graphql_name} was hidden due to permissions")
      end
    end
  end
end
