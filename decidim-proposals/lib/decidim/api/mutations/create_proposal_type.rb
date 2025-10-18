# frozen_string_literal: true

module Decidim
  module Proposals
    class CreateProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateProposal"

      description "Creates a proposal"
      type Decidim::Proposals::ProposalType

      argument :component_id, GraphQL::Types::ID, description: "The component ID where the proposal will be created", required: true
      argument :attributes, CreateProposalAttributes, description: "Input attributes for the proposal", required: true

      def resolve(component_id:, attributes:)
        component = Decidim::Component.find_by(id: component_id)
        
        return GraphQL::ExecutionError.new(
          I18n.t("decidim.proposals.create.error")
        ) unless component

        title = attributes.to_h.fetch(:title)
        body = attributes.to_h.fetch(:body)
        address = attributes.to_h.fetch(:address, nil)
        latitude = attributes.to_h.fetch(:latitude, nil)
        longitude = attributes.to_h.fetch(:longitude, nil)
        taxonomy_ids = attributes.to_h.fetch(:taxonomy_ids, [])

        params = {
          title:,
          body:,
          address:,
          latitude:,
          longitude:
        }

        # Add taxonomizations if taxonomy_ids provided
        if taxonomy_ids.any?
          taxonomies = Decidim::Taxonomy.where(id: taxonomy_ids)
          params[:taxonomizations] = taxonomies.map do |taxonomy|
            Decidim::Taxonomization.new(taxonomy:)
          end
        end

        form = Decidim::Proposals::ProposalForm.from_params(
          params
        ).with_context(
          current_component: component,
          current_user:,
          current_organization: current_user.organization
        )

        Decidim::Proposals::CreateProposal.call(form, current_user) do
          on(:ok) do |proposal|
            return proposal
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.proposals.create.error")
          )
        end
      end

      def authorized?(component_id:, attributes:)
        component = Decidim::Component.find_by(id: component_id)
        return false unless component

        super && allowed_to?(:create, :proposal, {}, { current_component: component })
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
