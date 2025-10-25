# frozen_string_literal: true

shared_examples "manage meeting mutation examples" do
  context "when meeting closing is not allowed" do
    it "does not close the meeting" do
      expect(response["close"]).to be_nil
    end
  end

  context "when meeting closing is allowed" do
    let!(:meeting_closing_allowed) { true }

    it "closes the meeting" do
      close = response["close"]
      expect(close).to be_present
      expect(close).to include(
        {
          "id" => model.id.to_s,
          "closed" => true,
          "attendeesCount" => attendees_count,
          "closingReport" => {
            "translation" => closing_report[:en]
          },
          "closedAt" => model.reload.closed_at.to_time.iso8601
        }
      )
    end

    context "with linked proposals" do
      let!(:proposals_component) { create(:proposal_component, participatory_space: participatory_process) }
      let!(:proposal1) { create(:proposal, component: proposals_component) }
      let!(:proposal2) { create(:proposal, component: proposals_component) }
      let!(:proposal_ids) { [proposal1.id, proposal2.id] }

      it "closes the meeting and links proposals" do
        close = response["close"]
        expect(close).to be_present
        
        # Verify the meeting is closed
        expect(close["closed"]).to be true
        
        # Verify proposals are linked
        expect(model.reload.linked_resources(:proposals, "proposals_from_meeting").pluck(:id)).to match_array(proposal_ids)
      end
    end
  end
end
