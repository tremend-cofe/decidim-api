# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Proposals
    describe VoteProposalType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { ProposalMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:proposal_component) do
        create(:proposal_component,
               :with_votes_enabled,
               participatory_space: participatory_process)
      end
      let!(:model) { create(:proposal, component: proposal_component) }
      let(:component) { model.component }
      let(:query) do
        <<~GRAPHQL
          mutation {
            vote {
              id
              voteCount
            }
          }
        GRAPHQL
      end

      context "with a normal user" do
        let(:user_type) { :user }

        context "when votes are enabled" do
          it "votes the proposal" do
            expect do
              expect(response["vote"]).not_to be_nil
            end.to change(ProposalVote, :count).by(1)
          end

          it "returns the proposal with updated vote count" do
            vote = response["vote"]
            expect(vote).to be_present
            expect(vote["id"]).to eq(model.id.to_s)
            expect(vote["voteCount"]).to eq(1)
          end
        end

        context "when the user has already voted" do
          before do
            create(:proposal_vote, proposal: model, author: current_user)
          end

          it "does not create a duplicate vote" do
            expect do
              response
            end.not_to change(ProposalVote, :count)
          end

          it "returns an error" do
            expect(response["vote"]).to be_nil
          end
        end

        context "when votes are disabled" do
          let(:proposal_component) do
            create(:proposal_component,
                   :with_votes_disabled,
                   participatory_space: participatory_process)
          end

          it "does not vote the proposal" do
            expect(response["vote"]).to be_nil
          end
        end

        context "when the proposal has reached maximum votes" do
          before do
            allow_any_instance_of(Proposal).to receive(:maximum_votes_reached?).and_return(true)
            allow_any_instance_of(Proposal).to receive(:can_accumulate_votes_beyond_threshold).and_return(false)
          end

          it "does not vote the proposal" do
            expect(response["vote"]).to be_nil
          end
        end
      end

      context "with an unauthenticated user" do
        let(:current_user) { nil }

        it "returns nil" do
          expect(response["vote"]).to be_nil
        end
      end
    end
  end
end
