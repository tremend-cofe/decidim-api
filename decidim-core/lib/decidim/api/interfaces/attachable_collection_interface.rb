# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an attachable object.
    module AttachableCollectionInterface
      include Decidim::Api::Types::Base::Interface
      description "An interface that can be used in objects with attachments"

      field :attachment_collections, [Decidim::Core::AttachmentCollectionType, { null: true }], "This object's attachment collections", null: false
    end
  end
end
