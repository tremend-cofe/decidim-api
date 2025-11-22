# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Proposals
    describe UpdateProposalType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:type_class) { Decidim::Proposals::UpdateProposalType }
      let(:root_klass) { ProposalMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:current_organization) { organization }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:author) { create(:user, organization:) }
      let!(:model) { create(:proposal, component: proposal_component, users: [author]) }
      let(:root_value) { model }
      let(:new_title) { "Updated proposal title for testing" }
      let(:new_body) { "This is an updated body content for the proposal that meets the minimum length requirements." }
      let(:component) { model.component }
      let(:variables) do
        {
          input: {
            attributes: {
              title: new_title,
              body: new_body
            }
          }
        }
      end
      let(:query) do
        <<~GRAPHQL
          mutation($input: UpdateProposalInput!) {
            updateProposal(input: $input) {
              id
              title { translation(locale: "en") }
              body { translation(locale: "en") }
              address
            }
          }
        GRAPHQL
      end

      context "with proposal author" do
        let!(:current_user) { author }

        it_behaves_like "update proposal mutation examples" do
          let!(:user_type) { :user }
        end
      end

      context "with admin user" do
        let!(:user_type) { :admin }

        it "does not update the proposal" do
          expect(response["updateProposal"]).to be_nil
        end
      end

      context "with normal user (not author)" do
        it "returns nil" do
          expect(response["updateProposal"]).to be_nil
        end
      end

      context "with api_user" do
        let!(:current_user) { author }

        it_behaves_like "update proposal mutation examples" do
          let!(:user_type) { :api_user }
        end
      end
    end
  end
end
