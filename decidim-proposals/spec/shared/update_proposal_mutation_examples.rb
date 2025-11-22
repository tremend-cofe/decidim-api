# frozen_string_literal: true

shared_examples "update proposal mutation examples" do
  context "when user is not authorized" do
    let!(:current_user) { nil }

    it "does not update the proposal" do
      expect(response["updateProposal"]).to be_nil
    end
  end

  context "when user is authorized" do
    context "with valid attributes" do
      it "updates the proposal" do
        update = response["updateProposal"]
        expect(update).to be_present
        expect(update).to include(
          {
            "id" => model.id.to_s,
            "title" => {
              "translation" => new_title
            },
            "body" => {
              "translation" => new_body
            }
          }
        )
      end

      context "with address and coordinates" do
        let(:address) { "Carrer de la Pau, 1, Barcelona" }
        let(:latitude) { 41.3851 }
        let(:longitude) { 2.1734 }
        let(:variables) do
          {
            input: {
              attributes: {
                title: new_title,
                body: new_body,
                address:,
                latitude:,
                longitude:
              }
            }
          }
        end

        it "updates the proposal with location data" do
          update = response["updateProposal"]
          expect(update).to be_present
          expect(update).to include(
            {
              "id" => model.id.to_s,
              "address" => address
            }
          )
        end
      end
    end

    context "with invalid attributes" do
      let(:new_title) { "short" }
      let(:new_body) { "x" }

      it "returns an error" do
        expect { response }.to raise_error(StandardError)
      end
    end
  end
end
