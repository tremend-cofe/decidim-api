# GraphQL Query Examples for CloseMeeting Mutation

## Basic Query Example

```graphql
# Query to close a meeting with basic information
mutation CloseMeeting {
  meetings(id: "COMPONENT_ID") {
    meeting(id: "123") {
      close(
        input: {
          attributes: {
            closingReport: { en: "The meeting concluded successfully with great participation." }
            attendeesCount: 25
          }
        }
      ) {
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

## Using Variables

```graphql
mutation CloseMeeting($componentId: ID!, $meetingId: ID!, $input: CloseMeetingInput!) {
  meetings(id: $componentId) {
    meeting(id: $meetingId) {
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

### Variables JSON:
```json
{
  "componentId": "1",
  "meetingId": "123",
  "input": {
    "attributes": {
      "closingReport": {
        "en": "The meeting was very productive. We discussed the main topics and reached consensus.",
        "es": "La reunión fue muy productiva. Discutimos los principales temas y llegamos a un consenso."
      },
      "attendeesCount": 30
    }
  }
}
```

## With Linked Proposals

```graphql
mutation CloseMeetingWithProposals($componentId: ID!, $meetingId: ID!, $input: CloseMeetingInput!) {
  meetings(id: $componentId) {
    meeting(id: $meetingId) {
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

### Variables JSON:
```json
{
  "componentId": "1",
  "meetingId": "456",
  "input": {
    "attributes": {
      "closingReport": {
        "en": "We finalized three proposals during this meeting.",
        "es": "Finalizamos tres propuestas durante esta reunión."
      },
      "attendeesCount": 42,
      "proposalIds": ["101", "102", "103"]
    }
  }
}
```

## With Custom Closed Date

```graphql
mutation CloseMeetingWithDate($componentId: ID!, $meetingId: ID!, $input: CloseMeetingInput!) {
  meetings(id: $componentId) {
    meeting(id: $meetingId) {
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

### Variables JSON:
```json
{
  "componentId": "1",
  "meetingId": "789",
  "input": {
    "attributes": {
      "closingReport": {
        "en": "Meeting closed with documented outcomes."
      },
      "attendeesCount": 50,
      "closedAt": "2024-10-25T15:30:00Z"
    }
  }
}
```

## Full Query with Additional Meeting Details

```graphql
mutation CloseMeetingFull($componentId: ID!, $meetingId: ID!, $input: CloseMeetingInput!) {
  meetings(id: $componentId) {
    meeting(id: $meetingId) {
      close(input: $input) {
        id
        title {
          translation(locale: "en")
        }
        closed
        attendeesCount
        closingReport {
          translation(locale: "en")
        }
        closedAt
        startTime
        endTime
        location {
          translation(locale: "en")
        }
      }
    }
  }
}
```

### Variables JSON:
```json
{
  "componentId": "1",
  "meetingId": "321",
  "input": {
    "attributes": {
      "closingReport": {
        "en": "Excellent meeting with productive discussions and concrete outcomes."
      },
      "attendeesCount": 35
    }
  }
}
```

## Testing Authentication

To test the mutation, you need to include an authentication token in your HTTP headers:

```
Authorization: Bearer YOUR_API_TOKEN
```

Or using session authentication:
```
Cookie: your-session-cookie
```

## Expected Responses

### Success Response:
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
            "translation": "The meeting concluded successfully..."
          },
          "closedAt": "2024-10-25T14:30:00Z"
        }
      }
    }
  }
}
```

### Permission Denied (returns null):
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

### Validation Error:
```json
{
  "data": null,
  "errors": [
    {
      "message": "Closing report can't be blank",
      "path": ["meetings", "meeting", "close"]
    }
  ]
}
```

## cURL Example

```bash
curl -X POST https://your-decidim-instance.com/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "query": "mutation CloseMeeting($componentId: ID!, $meetingId: ID!, $input: CloseMeetingInput!) { meetings(id: $componentId) { meeting(id: $meetingId) { close(input: $input) { id closed attendeesCount closingReport { translation(locale: \"en\") } closedAt } } } }",
    "variables": {
      "componentId": "1",
      "meetingId": "123",
      "input": {
        "attributes": {
          "closingReport": {
            "en": "Meeting closed successfully."
          },
          "attendeesCount": 30
        }
      }
    }
  }'
```

## Notes

1. Replace `COMPONENT_ID`, `meetingId`, and other IDs with actual values from your Decidim instance
2. The mutation requires admin or API user permissions
3. The meeting must exist and be editable
4. Closing reports support multiple locales
5. Proposal IDs must be from proposals in the same participatory space
