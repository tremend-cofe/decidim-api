# frozen_string_literal: true

module Decidim
  module Proposals
    class CreateProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateProposal"

      description "Creates a proposal"
      type Decidim::Proposals::ProposalType

      argument :attributes, CreateProposalAttributes, description: "Input attributes for the proposal", required: true

      def resolve(attributes:)
        # Get component from context (when called through ProposalsMutationType)
        # or from explicit component_id in test context
        component = object.is_a?(Decidim::Component) ? object : context[:current_component]
        
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

      def authorized?(attributes:)
        component = object.is_a?(Decidim::Component) ? object : context[:current_component]
        return false unless component

        super && allowed_to?(:create, :proposal, {}, { current_component: component })
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
