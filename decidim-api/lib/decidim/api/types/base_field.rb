# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseField < GraphQL::Schema::Field
        argument_class Decidim::Api::Types::Base::Argument
      end
    end
  end
end
