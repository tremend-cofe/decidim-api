# frozen_string_literal: true

module Decidim
  module Api
    module Types
      module BaseInterface
        include GraphQL::Schema::Interface

        field_class Decidim::Api::Types::Base::Field
      end
    end
  end
end
