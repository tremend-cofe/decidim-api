# frozen_string_literal: true

module Decidim
  module Core
    class ParticipatorySpaceType < Decidim::Api::Types::Base::Object
      implements ParticipatorySpaceInterface
      description "A participatory space"
    end
  end
end
