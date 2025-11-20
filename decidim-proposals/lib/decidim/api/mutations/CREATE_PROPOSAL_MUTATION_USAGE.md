# CreateProposal Mutation Usage Guide

## Overview

The `CreateProposal` mutation allows authenticated users to create new proposals in a Decidim component. This mutation follows the same pattern as the `ProposalAnswerType` mutation and uses the existing `CreateProposal` command from the controller.

## GraphQL Schema

### Input Type: CreateProposalAttributes

```graphql
input CreateProposalAttributes {
  title: String!              # Required: The title of the proposal (min 15, max 150 characters)
  body: String!               # Required: The body content of the proposal (min 15 characters)
  address: String             # Optional: Physical address for the proposal
  latitude: Float             # Optional: Latitude coordinate
  longitude: Float            # Optional: Longitude coordinate
}
```

### Mutation Definition

```graphql
mutation {
  component(id: ID!) {
    ... on ProposalsMutation {
      createProposal(
        attributes: CreateProposalAttributes!
      ): Proposal
    }
  }
}
```

## Usage Examples

### Example 1: Basic Proposal Creation

Create a simple proposal with title and body:

```graphql
mutation {
  component(id: "123") {
    ... on ProposalsMutation {
      createProposal(input: {
        attributes: {
          title: "Improve Public Transportation"
          body: "We need to expand bus routes to underserved neighborhoods to improve accessibility for all residents."
        }
      }) {
        id
        title {
          translation(locale: "en")
        }
        body {
          translation(locale: "en")
        }
        publishedAt
        state
      }
    }
  }
}
```

**Response:**

```json
{
  "data": {
    "createProposal": {
      "id": "456",
      "title": {
        "translation": "Improve Public Transportation"
      },
      "body": {
        "translation": "We need to expand bus routes to underserved neighborhoods to improve accessibility for all residents."
      },
      "publishedAt": null,
      "state": null
    }
  }
}
```

### Example 2: Proposal with Address and Coordinates

Create a proposal with geographic location:

```graphql
mutation {
  component(id: "123") {
    ... on ProposalsMutation {
      createProposal(input: {
        attributes: {
          title: "Install Bike Lanes on Main Street"
          body: "We propose adding dedicated bike lanes along Main Street to improve cyclist safety and encourage sustainable transportation."
          address: "Main Street, Barcelona, Spain"
          latitude: 41.3851
          longitude: 2.1734
        }
      }) {
        id
        title {
          translation(locale: "en")
        }
        address
        coordinates {
          latitude
          longitude
        }
      }
    }
  }
}
```

**Response:**

```json
{
  "data": {
    "createProposal": {
      "id": "457",
      "title": {
        "translation": "Install Bike Lanes on Main Street"
      },
      "address": "Main Street, Barcelona, Spain",
      "coordinates": {
        "latitude": 41.3851,
        "longitude": 2.1734
      }
    }
  }
}
```

### Example 3: Complete Example with All Fields

```graphql
mutation CreateCompleteProposal {
  component(id: "123") {
    ... on ProposalsMutation {
      createProposal(input: {
        attributes: {
          title: "Renovate Old Town Square for Accessibility"
          body: "The Old Town Square needs renovations to improve accessibility for people with disabilities. We propose installing ramps, accessible pathways, and better signage to make this historic area welcoming for all residents and visitors."
          address: "Old Town Square, Barcelona, Spain"
          latitude: 41.3879
          longitude: 2.1699
        }
      }) {
        id
        title {
          translation(locale: "en")
        }
        body {
          translation(locale: "en")
        }
        address
        coordinates {
          latitude
          longitude
        }
        taxonomies {
          id
          name {
            translation(locale: "en")
          }
        }
        publishedAt
        state
        createdAt
        coauthorships {
          author {
            ... on User {
              name
            }
          }
        }
      }
    }
  }
}
```

## Authentication Requirements

This mutation requires authentication. You can authenticate using:

1. **OAuth2 Token** (for API users):

   ```http request
   Authorization: Bearer YOUR_ACCESS_TOKEN
   ```

2. **User Session** (for web application):
   Session-based authentication for logged-in users

## Permissions

The mutation checks:

- User must be authenticated
- User must have permission to create proposals in the specified component
- Component must have proposal creation enabled in settings

## Error Handling

### Validation Errors

If the input fails validation, you'll receive an error response:

```json
{
  "data": {
    "createProposal": null
  },
  "errors": [
    {
      "message": "Title is too short (minimum is 15 characters), Body is too short (minimum is 15 characters)"
    }
  ]
}
```

### Permission Errors

If you don't have permission to create proposals:

```json
{
  "data": {
    "createProposal": null
  },
  "errors": [
    {
      "message": "You don't have permission to perform this action"
    }
  ]
}
```

## Important Notes

1. **Draft Status**: Newly created proposals are saved as drafts (publishedAt is null). Users need to publish them through the UI or a separate mutation.

2. **Title Length**: Must be between 15 and 150 characters.

3. **Body Length**: Must be at least 15 characters. Maximum length depends on component settings.

4. **Geocoding**: If you provide an address without coordinates, the system may attempt to geocode it automatically if geocoding is enabled in the component settings.

5. **Content Processing**: Title and body content will be processed for inline images and sanitized before being stored.

## Related Files

- **Mutation**: `decidim-proposals/lib/decidim/api/mutations/create_proposal_type.rb`
- **Input**: `decidim-proposals/lib/decidim/api/mutations/create_proposal_attributes.rb`
- **Command**: `decidim-proposals/app/commands/decidim/proposals/create_proposal.rb`
- **Form**: `decidim-proposals/app/forms/decidim/proposals/proposal_form.rb`
- **Controller**: `decidim-proposals/app/controllers/decidim/proposals/proposals_controller.rb` (see `create` method)

## Testing

Run the specs with:

```bash
bundle exec rspec decidim-proposals/spec/types/create_proposal_type_spec.rb
```

## References

This mutation was inspired by:

- `ProposalAnswerType` mutation pattern
- `ProposalAnswersController#create` method
- Decidim PRs: #14996, #14974, #14911, #14885, #14881
