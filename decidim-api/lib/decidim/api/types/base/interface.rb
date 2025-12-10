# frozen_string_literal: true

module Decidim
  module Api
    module Types
      module Base
        module Interface
          include GraphQL::Schema::Interface

          field_class Decidim::Api::Types::Base::Field
        end
      end
    end
  end
end
