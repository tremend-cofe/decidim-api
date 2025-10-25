# CloseMeeting GraphQL Mutation Documentation

## Overview

The `CloseMeeting` mutation allows authorized users (admins or API users with appropriate permissions) to close a meeting in Decidim. This mutation is equivalent to the functionality provided by the `CloseMeeting` command in `decidim-meetings/app/commands/decidim/meetings/close_meeting.rb`.

## Location

The mutation files are located in:
- **Mutation Type**: `decidim-meetings/lib/decidim/api/mutations/close_meeting_type.rb`
- **Input Attributes**: `decidim-meetings/lib/decidim/api/mutations/close_meeting_attributes.rb`
- **Meeting Mutation Type**: `decidim-meetings/lib/decidim/api/mutations/meeting_mutation_type.rb`
- **Meetings Mutation Type**: `decidim-meetings/lib/decidim/api/mutations/meetings_mutation_type.rb`

## Schema

### Input Type: CloseMeetingAttributes

```graphql
input CloseMeetingAttributes {
  closingReport: JSON!         # Required: The closing report for the meeting (localized content)
  attendeesCount: Int!         # Required: Number of attendees
  proposalIds: [ID]            # Optional: Array of proposal IDs to link to the meeting
  closedAt: DateTime           # Optional: The date and time when the meeting was closed (defaults to current time)
}
```

### Mutation Type: CloseMeeting

```graphql
mutation {
  close(input: CloseMeetingInput!): Meeting
}
```

Returns a `Meeting` object with updated fields including:
- `id`: The meeting ID
- `closed`: Boolean indicating if the meeting is closed
- `attendeesCount`: Number of attendees
- `closingReport`: The closing report (translated field)
- `closedAt`: The date and time when the meeting was closed

## Usage Examples

### Example 1: Basic Meeting Closure

Close a meeting with a closing report and attendee count:

```graphql
mutation CloseMeeting($input: CloseMeetingInput!) {
  meetings(id: COMPONENT_ID) {
    meeting(id: MEETING_ID) {
      close(input: $input) {
        id
        closed
        attendeesCount
        closingReport {
          translation(locale: "en")
        }
        closedAt
      }
    }
  }
}
```

**Variables:**

```json
{
  "input": {
    "attributes": {
      "closingReport": {
        "en": "The meeting was very productive. We discussed the main topics and reached consensus on several key points."
      },
      "attendeesCount": 25
    }
  }
}
```

### Example 2: Close Meeting with Linked Proposals

Close a meeting and link it to specific proposals:

```graphql
mutation CloseMeetingWithProposals($input: CloseMeetingInput!) {
  meetings(id: COMPONENT_ID) {
    meeting(id: MEETING_ID) {
      close(input: $input) {
        id
        closed
        attendeesCount
        closingReport {
          translation(locale: "en")
          translation(locale: "es")
        }
        closedAt
      }
    }
  }
}
```

**Variables:**

```json
{
  "input": {
    "attributes": {
      "closingReport": {
        "en": "The meeting concluded successfully with the following outcomes...",
        "es": "La reunión concluyó exitosamente con los siguientes resultados..."
      },
      "attendeesCount": 30,
      "proposalIds": ["123", "456", "789"]
    }
  }
}
```

### Example 3: Close Meeting with Custom Closed Date

Close a meeting with a specific closed date/time:

```graphql
mutation CloseMeetingCustomDate($input: CloseMeetingInput!) {
  meetings(id: COMPONENT_ID) {
    meeting(id: MEETING_ID) {
      close(input: $input) {
        id
        closed
        attendeesCount
        closingReport {
          translation(locale: "en")
        }
        closedAt
      }
    }
  }
}
```

**Variables:**

```json
{
  "input": {
    "attributes": {
      "closingReport": {
        "en": "Meeting closed with detailed outcomes and action items."
      },
      "attendeesCount": 42,
      "closedAt": "2024-10-25T15:30:00Z"
    }
  }
}
```

## Authorization

The mutation checks for authorization using the `:close` action on `:meeting` resource. Only users with the appropriate permissions (typically admins or API users with proper credentials) can close meetings.

**Authorization Check:**
```ruby
allowed_to?(:close, :meeting, object, context, meeting: object)
```

## Error Handling

The mutation will return a `GraphQL::ExecutionError` in the following cases:

1. **Validation Errors**: If the form validation fails (e.g., missing required fields, invalid attendee count)
   - Error message: The specific validation errors joined by commas

2. **Permission Denied**: If the user doesn't have permission to close the meeting
   - The mutation will return `nil`

3. **General Errors**: Any other errors during the closing process
   - Error message: `"decidim.meetings.admin.meetings.close.invalid"`

## Example Response

**Success Response:**

```json
{
  "data": {
    "meetings": {
      "meeting": {
        "close": {
          "id": "123",
          "closed": true,
          "attendeesCount": 25,
          "closingReport": {
            "translation": "The meeting was very productive..."
          },
          "closedAt": "2024-10-25T14:30:00Z"
        }
      }
    }
  }
}
```

**Error Response (Permission Denied):**

```json
{
  "data": {
    "meetings": {
      "meeting": {
        "close": null
      }
    }
  }
}
```

**Error Response (Validation Error):**

```json
{
  "data": null,
  "errors": [
    {
      "message": "Closing report can't be blank, Attendees count must be greater than or equal to 0",
      "path": ["meetings", "meeting", "close"],
      "extensions": {
        "code": "GRAPHQL_EXECUTION_ERROR"
      }
    }
  ]
}
```

## Testing

The mutation includes comprehensive test coverage in:
- **Spec File**: `decidim-meetings/spec/types/close_meeting_type_spec.rb`
- **Shared Examples**: `decidim-meetings/spec/shared/meeting_mutation_examples.rb`

Tests cover:
- Admin user access
- API user access
- Normal user (unauthorized) access
- Meeting closure with and without proposal links
- Validation error handling

## Related Files

- **Command**: `decidim-meetings/app/commands/decidim/meetings/close_meeting.rb`
- **Form**: `decidim-meetings/app/forms/decidim/meetings/close_meeting_form.rb`
- **Controller**: `decidim-meetings/app/controllers/decidim/meetings/meeting_closes_controller.rb`
- **API Type**: `decidim-meetings/lib/decidim/api/meeting_type.rb`

## Notes

1. The mutation uses the existing `CloseMeeting` command, ensuring consistency with the web UI functionality.
2. The `closing_report` is processed through `Decidim::ContentProcessor` to handle localization and content parsing.
3. Proposals are linked to the meeting using the `proposals_from_meeting` relationship.
4. The meeting's `closing_visible` flag is automatically set to `true` when closing.
5. An event is published when a meeting is closed, notifying followers via `Decidim::Meetings::CloseMeetingEvent`.
