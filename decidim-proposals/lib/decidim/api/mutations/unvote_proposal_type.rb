# frozen_string_literal: true

module Decidim
  module Proposals
    class UnvoteProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "UnvoteProposal"

      description "Removes a vote from a proposal"
      type Decidim::Proposals::ProposalType

      def resolve
        UnvoteProposal.call(object, current_user) do
          on(:ok) do
            return object.reload
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              I18n.t("proposal_votes.destroy.error", scope: "decidim.proposals")
            )
          end
        end

        GraphQL::ExecutionError.new(
          I18n.t("proposal_votes.destroy.error", scope: "decidim.proposals")
        )
      end

      def authorized?
        super && allowed_to?(:unvote, :proposal, object, context)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
