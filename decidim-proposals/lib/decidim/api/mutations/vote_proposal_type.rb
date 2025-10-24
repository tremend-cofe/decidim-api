# frozen_string_literal: true

module Decidim
  module Proposals
    class VoteProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "VoteProposal"

      description "Votes a proposal"
      type Decidim::Proposals::ProposalType

      def resolve
        VoteProposal.call(object, current_user) do
          on(:ok) do
            return object.reload
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              I18n.t("proposal_votes.create.error", scope: "decidim.proposals")
            )
          end
        end

        GraphQL::ExecutionError.new(
          I18n.t("proposal_votes.create.error", scope: "decidim.proposals")
        )
      end

      def authorized?
        super && allowed_to?(:vote, :proposal, object, context)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
