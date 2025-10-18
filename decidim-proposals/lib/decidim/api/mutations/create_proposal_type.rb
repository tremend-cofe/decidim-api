# frozen_string_literal: true

module Decidim
  module Proposals
    class CreateProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateProposal"

      description "Creates a proposal"
      type Decidim::Proposals::ProposalType

      argument :attributes, ProposalAttributes, description: "Input attributes for the proposal", required: true

      def resolve(attributes:)
        params = attributes.to_h.slice(:title, :body, :address, :latitude, :longitude, :taxonomies)

        params[:taxonomies] = Decidim::Taxonomy.where(id: params[:taxonomies]).pluck(:id) if params[:taxonomies]

        form = Decidim::Proposals::ProposalForm.from_params(
          params
        ).with_context(
          current_component:,
          current_user:,
          current_organization: current_user.organization
        )

        Decidim::Proposals::CreateProposal.call(form, current_user) do
          on(:ok) do |proposal|
            Decidim::Proposals::PublishProposal.call(proposal, current_user) do
              on(:ok) do
                return proposal.reload
              end

              on(:invalid) do
                raise GraphQL::ExecutionError, I18n.t("proposals.publish.error", scope: "decidim")
              end
            end
          end

          on(:invalid) do
            raise GraphQL::ExecutionError, form.errors.full_messages.join(", ")
          end
        end
      end

      def authorized?(attributes:)
        component = object.is_a?(Decidim::Component) ? object : context[:current_component]
        return false unless component

        super && allowed_to?(:create, :proposal, Decidim::Proposals::Proposal.new(component:), { current_user:, current_component: })
      end
    end
  end
end
