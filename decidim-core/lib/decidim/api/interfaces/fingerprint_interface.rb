# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a fingerprintable object.
    module FingerprintInterface
      include Decidim::Api::Types::Base::Interface
      description "An interface that can be used in fingerprintable objects."

      field :fingerprint, Decidim::Core::FingerprintType, "This object's fingerprint", null: false
    end
  end
end
