# frozen_string_literal: true

module Decidim
  module Proposals
    class WithdrawProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "WithdrawProposal"

      description "Withdraws a proposal"
      type Decidim::Proposals::ProposalType

      def resolve
        WithdrawProposal.call(object, current_user) do
          on(:ok) do |proposal|
            return proposal
          end
          on(:has_votes) do
            raise GraphQL::ExecutionError.new(
              I18n.t("proposals.withdraw.errors.has_votes", scope: "decidim")
            )
          end
        end
      end

      def authorized?
        super && allowed_to?(:withdraw, :proposal, object, context)
      end
    end
  end
end
