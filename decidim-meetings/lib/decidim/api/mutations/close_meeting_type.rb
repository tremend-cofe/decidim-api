# frozen_string_literal: true

module Decidim
  module Meetings
    class CloseMeetingType < Decidim::Api::Types::BaseMutation
      graphql_name "CloseMeeting"

      description "Closes a meeting"
      type Decidim::Meetings::MeetingType

      argument :attributes, CloseMeetingAttributes, description: "input attributes for closing a meeting", required: true

      def resolve(attributes:)
        closing_report = attributes.to_h.fetch(:closing_report, object.closing_report)
        attendees_count = attributes.to_h.fetch(:attendees_count, object.attendees_count)
        proposal_ids = attributes.to_h.fetch(:proposal_ids, [])
        closed_at = attributes.to_h.fetch(:closed_at, Time.current)
        
        params = {
          closing_report:,
          attendees_count:,
          proposal_ids:,
          closed_at:,
          proposals: object.sibling_scope(:proposals)
        }

        form = Decidim::Meetings::CloseMeetingForm.from_params(
          params
        ).with_context(
          current_component: object.component,
          current_user:,
          current_organization: current_user.organization
        )

        CloseMeeting.call(form, object) do
          on(:ok) do
            return object
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.meetings.admin.meetings.close.invalid")
          )
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:close, :meeting, object, context)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
