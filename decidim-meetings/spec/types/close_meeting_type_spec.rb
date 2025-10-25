# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Meetings
    describe CloseMeetingType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { MeetingMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:meetings_component) { create(:meeting_component, participatory_space: participatory_process) }
      let!(:model) { create(:meeting, component: meetings_component, end_time: 1.day.ago) }
      let(:attendees_count) { 10 }
      let(:closing_report) { Decidim::Faker::Localized.sentence(word_count: 3) }
      let(:meeting_closing_allowed) { false }
      let(:component) { model.component }
      let(:proposal_ids) { [] }
      
      let(:variables) do
        {
          input: {
            attributes: {
              closingReport: closing_report,
              attendesCount: attendees_count,
              proposalIds: proposal_ids
            }
          }
        }
      end
      
      let(:query) do
        <<~GRAPHQL
          mutation($input: CloseMeetingInput!) {
            close(input: $input) {
              id
              closed
              attendesCount
              closingReport { translation(locale: "en") }
              closedAt
            }
          }
        GRAPHQL
      end

      context "with admin user" do
        it_behaves_like "manage meeting mutation examples" do
          let!(:user_type) { :admin }
        end
      end

      context "with normal user" do
        it "returns nil" do
          expect(response["close"]).to be_nil
        end
      end

      context "with api_user" do
        it_behaves_like "manage meeting mutation examples" do
          let!(:user_type) { :api_user }
        end
      end
    end
  end
end
