# frozen_string_literal: true

module Decidim
  module Api
    module Types
      module Base
        class InputObject < GraphQL::Schema::InputObject
          argument_class Decidim::Api::Types::Base::Argument
        end
      end
    end
  end
end
