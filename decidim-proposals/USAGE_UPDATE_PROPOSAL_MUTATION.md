# UpdateProposal GraphQL Mutation - Usage Documentation

## Overview

The `UpdateProposal` mutation allows authenticated users to update their existing proposals through the Decidim GraphQL API. This mutation follows the same pattern as the existing `ProposalAnswer` mutation.

## Prerequisites

- User must be authenticated (via API token or session)
- User must have permissions to edit the proposal (must be the author or have admin rights)
- The proposal must be editable (not withdrawn, not in a locked state)

## GraphQL Schema

### Input Type: UpdateProposalAttributes

```graphql
input UpdateProposalAttributes {
  title: String!              # Required: The title of the proposal (15-150 characters)
  body: String!               # Required: The body content of the proposal (minimum 15 characters)
  address: String             # Optional: Physical address (requires geocoding enabled)
  latitude: Float             # Optional: Latitude coordinate
  longitude: Float            # Optional: Longitude coordinate
}
```

### Mutation Field

```graphql
mutation {
  proposals {
    proposal(id: "123") {
      update(input: UpdateProposalInput!) {
        id
        title { translation(locale: "en") }
        body { translation(locale: "en") }
        address
        # ... other proposal fields
      }
    }
  }
}
```

## Full Usage Examples

### Example 1: Basic Proposal Update

Update just the title and body of a proposal:

```graphql
mutation UpdateProposal($input: UpdateProposalInput!) {
  proposals {
    proposal(id: "123") {
      update(input: $input) {
        id
        title { translation(locale: "en") }
        body { translation(locale: "en") }
        updatedAt
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
      "title": "Updated Proposal Title - More Descriptive",
      "body": "This is the updated body content of the proposal with more detailed information about the proposal."
    }
  }
}
```

### Example 2: Update with Location Data

Update a proposal including address and coordinates:

```graphql
mutation UpdateProposalWithLocation($input: UpdateProposalInput!) {
  proposals {
    proposal(id: "123") {
      update(input: $input) {
        id
        title { translation(locale: "en") }
        body { translation(locale: "en") }
        address
        coordinates {
          latitude
          longitude
        }
        updatedAt
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
      "title": "Community Park Improvement Proposal",
      "body": "This proposal aims to improve the local community park by adding new playground equipment, benches, and improved lighting for safety.",
      "address": "Carrer de la Pau, 1, 08001 Barcelona, Spain",
      "latitude": 41.3851,
      "longitude": 2.1734
    }
  }
}
```

### Example 3: Comprehensive Response with All Fields

Request all available fields after update:

```graphql
mutation UpdateProposalComplete($input: UpdateProposalInput!) {
  proposals {
    proposal(id: "123") {
      update(input: $input) {
        id
        title { 
          translation(locale: "en") 
          locales
        }
        body { 
          translation(locale: "en") 
        }
        address
        coordinates {
          latitude
          longitude
        }
        state
        createdAt
        updatedAt
        publishedAt
        participatoryTextLevel
        position
        reference
        voteCount {
          total
        }
        authors {
          ... on User {
            name
          }
        }
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
      "title": "Complete Update Example - Enhanced Proposal",
      "body": "This is a comprehensive example showing how to update a proposal with all relevant fields and retrieve complete information."
    }
  }
}
```

## HTTP Request Example

Using cURL to make the GraphQL request:

```bash
curl -X POST https://your-decidim-instance.org/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "query": "mutation UpdateProposal($input: UpdateProposalInput!) { proposals { proposal(id: \"123\") { update(input: $input) { id title { translation(locale: \"en\") } body { translation(locale: \"en\") } } } } }",
    "variables": {
      "input": {
        "attributes": {
          "title": "Updated Proposal Title",
          "body": "Updated proposal body content with sufficient length to meet requirements."
        }
      }
    }
  }'
```

## JavaScript/TypeScript Example

Using Apollo Client:

```typescript
import { gql, useMutation } from '@apollo/client';

const UPDATE_PROPOSAL = gql`
  mutation UpdateProposal($proposalId: ID!, $input: UpdateProposalInput!) {
    proposals {
      proposal(id: $proposalId) {
        update(input: $input) {
          id
          title { translation(locale: "en") }
          body { translation(locale: "en") }
          updatedAt
        }
      }
    }
  }
`;

function UpdateProposalComponent({ proposalId }) {
  const [updateProposal, { data, loading, error }] = useMutation(UPDATE_PROPOSAL);

  const handleUpdate = async () => {
    try {
      const result = await updateProposal({
        variables: {
          proposalId: proposalId,
          input: {
            attributes: {
              title: "Updated Title from React App",
              body: "This is the updated body content from the React application with proper length."
            }
          }
        }
      });
      console.log('Proposal updated:', result.data);
    } catch (err) {
      console.error('Error updating proposal:', err);
    }
  };

  return (
    <button onClick={handleUpdate} disabled={loading}>
      {loading ? 'Updating...' : 'Update Proposal'}
    </button>
  );
}
```

## Python Example

Using the `requests` library:

```python
import requests
import json

def update_proposal(api_url, token, proposal_id, title, body, address=None, latitude=None, longitude=None):
    """
    Update a Decidim proposal via GraphQL API
    
    Args:
        api_url: The GraphQL API endpoint URL
        token: API authentication token
        proposal_id: ID of the proposal to update
        title: New title for the proposal
        body: New body content for the proposal
        address: Optional address
        latitude: Optional latitude coordinate
        longitude: Optional longitude coordinate
    
    Returns:
        dict: The updated proposal data or error information
    """
    
    query = """
    mutation UpdateProposal($input: UpdateProposalInput!) {
      proposals {
        proposal(id: "%s") {
          update(input: $input) {
            id
            title { translation(locale: "en") }
            body { translation(locale: "en") }
            address
            updatedAt
          }
        }
      }
    }
    """ % proposal_id
    
    variables = {
        "input": {
            "attributes": {
                "title": title,
                "body": body
            }
        }
    }
    
    # Add optional location data if provided
    if address:
        variables["input"]["attributes"]["address"] = address
    if latitude is not None:
        variables["input"]["attributes"]["latitude"] = latitude
    if longitude is not None:
        variables["input"]["attributes"]["longitude"] = longitude
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}"
    }
    
    payload = {
        "query": query,
        "variables": variables
    }
    
    response = requests.post(api_url, json=payload, headers=headers)
    
    if response.status_code == 200:
        return response.json()
    else:
        return {
            "error": f"HTTP {response.status_code}",
            "message": response.text
        }

# Usage example
if __name__ == "__main__":
    result = update_proposal(
        api_url="https://your-decidim-instance.org/api",
        token="your_api_token_here",
        proposal_id="123",
        title="Updated Proposal from Python Script",
        body="This proposal has been updated programmatically using Python with sufficient content length.",
        address="Example Street, 123, Barcelona",
        latitude=41.3851,
        longitude=2.1734
    )
    
    print(json.dumps(result, indent=2))
```

## Error Handling

### Common Errors

1. **Unauthorized**: User doesn't have permission to edit the proposal
```json
{
  "errors": [
    {
      "message": "Not authorized",
      "extensions": {
        "code": "UNAUTHORIZED"
      }
    }
  ]
}
```

2. **Validation Error**: Title or body doesn't meet requirements
```json
{
  "errors": [
    {
      "message": "Title is too short (minimum is 15 characters), Body is too short (minimum is 15 characters)"
    }
  ]
}
```

3. **Proposal Not Found**: Invalid proposal ID
```json
{
  "errors": [
    {
      "message": "Proposal not found"
    }
  ]
}
```

### Error Handling Example

```javascript
try {
  const result = await updateProposal({
    variables: { proposalId, input: { attributes: { title, body } } }
  });
  
  if (result.errors) {
    // Handle GraphQL errors
    console.error('GraphQL errors:', result.errors);
    result.errors.forEach(error => {
      if (error.extensions?.code === 'UNAUTHORIZED') {
        // Handle authorization error
        showError('You do not have permission to update this proposal');
      } else {
        // Handle other errors
        showError(error.message);
      }
    });
  } else {
    // Success
    console.log('Proposal updated successfully:', result.data);
  }
} catch (networkError) {
  // Handle network errors
  console.error('Network error:', networkError);
  showError('Failed to connect to the server');
}
```

## Validation Rules

The following validation rules apply when updating a proposal:

1. **Title**: 
   - Required
   - Minimum length: 15 characters
   - Maximum length: 150 characters

2. **Body**: 
   - Required
   - Minimum length: 15 characters
   - Maximum length: Configurable per component (default varies)

3. **Address**: 
   - Optional
   - Only available if geocoding is enabled for the component
   - Must be a valid address if provided

4. **Coordinates**: 
   - Optional
   - Both latitude and longitude must be provided together
   - Must be valid coordinate values

5. **Permissions**:
   - User must be authenticated
   - User must be the proposal author OR have admin rights
   - Proposal must be in editable state (not withdrawn, not locked)

## API Authentication

### Using OAuth 2.0 Token

```bash
# First, obtain a token (example endpoint)
curl -X POST https://your-decidim-instance.org/oauth/token \
  -d "grant_type=client_credentials" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "scope=api:read api:write"

# Use the token in your mutation request
curl -X POST https://your-decidim-instance.org/api \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"...", "variables":{...}}'
```

## Related Mutations

- `Answer`: Answer a proposal (admin only)
- `CreateProposal`: Create a new proposal
- `WithdrawProposal`: Withdraw a proposal

## Notes

- The mutation follows the Relay mutation pattern with an input wrapper
- Translations are handled automatically based on the current locale
- All text content is processed for security (XSS prevention, HTML sanitization)
- The proposal's `updatedAt` timestamp is automatically updated
- Version history is maintained using PaperTrail for published proposals

## Support

For issues or questions about this mutation:
1. Check the Decidim documentation: https://docs.decidim.org/
2. Visit the Decidim community: https://decidim.org/community/
3. Open an issue on GitHub: https://github.com/decidim/decidim/issues
