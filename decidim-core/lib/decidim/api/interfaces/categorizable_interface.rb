# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a categorizable object.
    module CategorizableInterface
      include Decidim::Api::Types::Base::Interface
      description "An interface that can be used in categorizable objects."

      field :category, Decidim::Core::CategoryType, "The object's category", null: true
    end
  end
end
