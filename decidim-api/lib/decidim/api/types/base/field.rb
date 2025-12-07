# frozen_string_literal: true

module Decidim
  module Api
    module Types
      module Base
        class Field < GraphQL::Schema::Field
          argument_class Decidim::Api::Types::Base::Argument
        end
      end
    end
  end
end
