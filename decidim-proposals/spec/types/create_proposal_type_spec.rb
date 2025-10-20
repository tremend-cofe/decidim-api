# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Proposals
    describe CreateProposalType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:type_class) { Decidim::Proposals::CreateProposalType }
      let(:root_klass) { Decidim::Proposals::ProposalsMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:component) { proposal_component }
      let(:title) { "A great proposal title" }
      let(:body) { "This is the body of my proposal with enough content to be valid" }
      let(:address) { "Carrer de la Pau, 1, Barcelona" }
      let(:latitude) { 41.3851 }
      let(:longitude) { 2.1734 }
      let(:taxonomies) { [] }
      let(:variables) do
        {
          component_id: proposal_component.id,
          input: {
            attributes: {
              title:,
              body:,
              address:,
              latitude:,
              longitude:,
              taxonomies:
            }
          }
        }
      end
      let(:root_value) { component }
      let(:query) do
        <<~GRAPHQL
          mutation createProposal($input: CreateProposalInput!){
            createProposal(input: $input) {
              id
              title { translation(locale: "en") }
              body { translation(locale: "en") }
              address
              publishedAt
            }
          }
        GRAPHQL
      end

      before do
        component.update!(
          settings: { creation_enabled: true }
        )
      end

      context "with admin user" do
        let(:user_type) { :admin }

        it "creates the proposal" do
          proposal_response = response["createProposal"]

          pp response


          expect(proposal_response).to be_present
          expect(proposal_response["title"]["translation"]).to eq(title)
          expect(proposal_response["body"]["translation"]).to include(body)
          expect(proposal_response["address"]).to eq(address)
          expect(proposal_response["publishedAt"]).to be_nil # Proposals are created as drafts
        end

        context "with taxonomy_ids" do
          let(:taxonomy) { create(:taxonomy, organization:) }
          let(:taxonomies) { [taxonomy.id.to_s] }

          it "creates the proposal with taxonomies" do
            proposal_response = response["createProposal"]
            expect(proposal_response).to be_present

            created_proposal = Decidim::Proposals::Proposal.find(proposal_response["id"])
            expect(created_proposal.taxonomies).to include(taxonomy)
          end
        end

        context "with invalid title" do
          let(:title) { "Short" }

          it "raises an error" do
            expect { response }.to raise_error(StandardError, /too short/)
          end
        end

        context "with invalid body" do
          let(:body) { "Short" }

          it "raises an error" do
            expect { response }.to raise_error(StandardError, /too short/)
          end
        end

        context "without title" do
          let(:title) { "" }

          it "raises an error" do
            expect { response }.to raise_error(StandardError, /blank/)
          end
        end
      end

      context "with normal user" do
        let(:user_type) { :user }

        it "creates the proposal" do
          proposal_response = response["createProposal"]
          expect(proposal_response).to be_present
          expect(proposal_response["title"]["translation"]).to eq(title)
        end

        context "when creation is disabled" do
          before do
            component.update!(
              settings: { creation_enabled: false }
            )
          end

          it "returns nil" do
            expect(response["createProposal"]).to be_nil
          end
        end
      end

      context "with api_user" do
        let(:user_type) { :api_user }

        it "creates the proposal" do
          proposal_response = response["createProposal"]
          expect(proposal_response).to be_present
          expect(proposal_response["title"]["translation"]).to eq(title)
        end
      end

      context "without authentication" do
        let(:current_user) { nil }

        it "returns nil" do
          expect(response["createProposal"]).to be_nil
        end
      end
    end
  end
end
