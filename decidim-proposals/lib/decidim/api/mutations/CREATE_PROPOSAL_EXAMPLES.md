# CreateProposal Mutation - Practical Examples

This document provides practical examples for calling the CreateProposal mutation using different tools.

## Using cURL

### Example 1: Basic Request with OAuth Token

```bash
curl -X POST https://your-decidim-instance.com/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "query": "mutation CreateProposal($componentId: ID!, $title: String!, $body: String!) { component(id: $componentId) { ... on ProposalsMutation { createProposal(input: { attributes: { title: $title, body: $body } }) { id title { translation(locale: \"en\") } body { translation(locale: \"en\") } publishedAt } } } }",
    "variables": {
      "componentId": "123",
      "title": "Improve Public Transportation",
      "body": "We need to expand bus routes to underserved neighborhoods to improve accessibility for all residents."
    }
  }'
```

### Example 2: Complete Request with All Fields

```bash
curl -X POST https://your-decidim-instance.com/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "query": "mutation CreateProposal($componentId: ID!, $input: CreateProposalAttributesInput!) { component(id: $componentId) { ... on ProposalsMutation { createProposal(input: { attributes: $input }) { id title { translation(locale: \"en\") } body { translation(locale: \"en\") } address publishedAt state } } } }",
    "variables": {
      "componentId": "123",
      "input": {
        "title": "Install Bike Lanes on Main Street",
        "body": "We propose adding dedicated bike lanes along Main Street to improve cyclist safety and encourage sustainable transportation.",
        "address": "Main Street, Barcelona, Spain",
        "latitude": 41.3851,
        "longitude": 2.1734,
        "taxonomyIds": ["789", "790"]
      }
    }
  }'
```

## Using JavaScript/TypeScript

### Example with Fetch API

```javascript
const CREATE_PROPOSAL_MUTATION = `
  mutation CreateProposal($componentId: ID!, $attributes: CreateProposalAttributesInput!) {
    component(id: $componentId) {
      ... on ProposalsMutation {
        createProposal(input: { attributes: $attributes }) {
          id
          title {
            translation(locale: "en")
          }
          body {
            translation(locale: "en")
          }
          publishedAt
        }
      }
    }
  }
`;

async function createProposal(accessToken, componentId, proposalData) {
  const response = await fetch('https://your-decidim-instance.com/api', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`
    },
    body: JSON.stringify({
      query: CREATE_PROPOSAL_MUTATION,
      variables: {
        componentId: componentId,
        attributes: proposalData
      }
    })
  });

  const result = await response.json();
  
  if (result.errors) {
    throw new Error(result.errors.map(e => e.message).join(', '));
  }
  
  return result.data.component.createProposal;
}

// Usage
const proposalData = {
  title: "Improve Public Transportation",
  body: "We need to expand bus routes to underserved neighborhoods to improve accessibility for all residents.",
  address: "Main Street, Barcelona, Spain",
  latitude: 41.3851,
  longitude: 2.1734,
  taxonomyIds: ["789"]
};

createProposal('YOUR_ACCESS_TOKEN', '123', proposalData)
  .then(proposal => {
    console.log('Proposal created:', proposal.id);
    console.log('Title:', proposal.title.translation);
  })
  .catch(error => {
    console.error('Error creating proposal:', error);
  });
```

### Example with Apollo Client

```javascript
import { gql, useMutation } from '@apollo/client';

const CREATE_PROPOSAL = gql`
  mutation CreateProposal($componentId: ID!, $attributes: CreateProposalAttributesInput!) {
    component(id: $componentId) {
      ... on ProposalsMutation {
        createProposal(input: { attributes: $attributes }) {
          id
          title {
            translation(locale: "en")
          }
          body {
            translation(locale: "en")
          }
          address
          publishedAt
          state
        }
      }
    }
  }
`;

function CreateProposalForm() {
  const [createProposal, { data, loading, error }] = useMutation(CREATE_PROPOSAL);

  const handleSubmit = async (formData) => {
    try {
      const result = await createProposal({
        variables: {
          componentId: '123',
          attributes: {
            title: formData.title,
            body: formData.body,
            address: formData.address,
            latitude: formData.latitude,
            longitude: formData.longitude,
            taxonomyIds: formData.taxonomyIds
          }
        }
      });
      
      console.log('Created proposal:', result.data.component.createProposal);
    } catch (err) {
      console.error('Error:', err);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Your form fields here */}
    </form>
  );
}
```

## Using Python

### Example with requests library

```python
import requests
import json

def create_proposal(access_token, component_id, proposal_data):
    """
    Create a proposal using the GraphQL API
    
    Args:
        access_token (str): OAuth access token
        component_id (str): Component ID where the proposal will be created
        proposal_data (dict): Proposal attributes (title, body, address, etc.)
    
    Returns:
        dict: Created proposal data
    """
    
    query = """
    mutation CreateProposal($componentId: ID!, $attributes: CreateProposalAttributesInput!) {
        component(id: $componentId) {
            ... on ProposalsMutation {
                createProposal(input: { attributes: $attributes }) {
                    id
                    title {
                        translation(locale: "en")
                    }
                    body {
                        translation(locale: "en")
                    }
                    publishedAt
                }
            }
        }
    }
    """
    
    variables = {
        "componentId": component_id,
        "attributes": proposal_data
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {access_token}"
    }
    
    response = requests.post(
        "https://your-decidim-instance.com/api",
        json={"query": query, "variables": variables},
        headers=headers
    )
    
    result = response.json()
    
    if "errors" in result:
        raise Exception(", ".join([e["message"] for e in result["errors"]]))
    
    return result["data"]["component"]["createProposal"]


# Usage example
if __name__ == "__main__":
    access_token = "YOUR_ACCESS_TOKEN"
    component_id = "123"
    
    proposal_data = {
        "title": "Improve Public Transportation",
        "body": "We need to expand bus routes to underserved neighborhoods to improve accessibility for all residents.",
        "address": "Main Street, Barcelona, Spain",
        "latitude": 41.3851,
        "longitude": 2.1734,
        "taxonomyIds": ["789", "790"]
    }
    
    try:
        proposal = create_proposal(access_token, component_id, proposal_data)
        print(f"Proposal created with ID: {proposal['id']}")
        print(f"Title: {proposal['title']['translation']}")
    except Exception as e:
        print(f"Error creating proposal: {e}")
```

## Using Ruby

### Example with net/http

```ruby
require 'net/http'
require 'json'
require 'uri'

def create_proposal(access_token, component_id, proposal_data)
  query = <<~GRAPHQL
    mutation CreateProposal($componentId: ID!, $attributes: CreateProposalAttributesInput!) {
      component(id: $componentId) {
        ... on ProposalsMutation {
          createProposal(input: { attributes: $attributes }) {
            id
            title {
              translation(locale: "en")
            }
            body {
              translation(locale: "en")
            }
            publishedAt
          }
        }
      }
    }
  GRAPHQL

  uri = URI.parse("https://your-decidim-instance.com/api")
  
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{access_token}"
  
  request.body = JSON.dump({
    query: query,
    variables: {
      componentId: component_id,
      attributes: proposal_data
    }
  })
  
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
  
  result = JSON.parse(response.body)
  
  if result["errors"]
    raise result["errors"].map { |e| e["message"] }.join(", ")
  end
  
  result.dig("data", "component", "createProposal")
end

# Usage
proposal_data = {
  title: "Improve Public Transportation",
  body: "We need to expand bus routes to underserved neighborhoods to improve accessibility for all residents.",
  address: "Main Street, Barcelona, Spain",
  latitude: 41.3851,
  longitude: 2.1734,
  taxonomyIds: ["789"]
}

begin
  proposal = create_proposal("YOUR_ACCESS_TOKEN", "123", proposal_data)
  puts "Proposal created with ID: #{proposal['id']}"
  puts "Title: #{proposal.dig('title', 'translation')}"
rescue => e
  puts "Error creating proposal: #{e.message}"
end
```

## Getting an OAuth Access Token

Before you can use the mutation, you need to obtain an OAuth access token. Here's how:

### 1. Register an OAuth Application

In your Decidim instance, go to:
- User menu → Account Settings → Applications
- Click "New application"
- Fill in the details and select the scopes: `api:read` and `api:write`
- Note the Client ID and Client Secret

### 2. Get an Access Token

```bash
# For password grant (if enabled)
curl -X POST https://your-decidim-instance.com/oauth/token \
  -d "grant_type=password" \
  -d "username=user@example.com" \
  -d "password=yourpassword" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "scope=api:read api:write"

# For authorization code flow (recommended)
# Step 1: Direct user to authorization URL
https://your-decidim-instance.com/oauth/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&response_type=code&scope=api:read+api:write

# Step 2: Exchange authorization code for token
curl -X POST https://your-decidim-instance.com/oauth/token \
  -d "grant_type=authorization_code" \
  -d "code=AUTHORIZATION_CODE" \
  -d "redirect_uri=YOUR_REDIRECT_URI" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET"
```

The response will contain an `access_token` that you can use for API requests.

## Error Handling

Common errors and their solutions:

### Invalid Title or Body

```json
{
  "errors": [
    {
      "message": "Title is too short (minimum is 15 characters)"
    }
  ]
}
```

**Solution**: Ensure title is between 15-150 characters and body is at least 15 characters.

### Unauthorized

```json
{
  "errors": [
    {
      "message": "You don't have permission to perform this action"
    }
  ]
}
```

**Solution**: Check that:
- Your access token is valid and has `api:write` scope
- Proposal creation is enabled in the component settings
- You have permission to create proposals

### Invalid Component ID

```json
{
  "errors": [
    {
      "message": "Component not found"
    }
  ]
}
```

**Solution**: Verify the component ID exists and is a proposals component.

## Testing in GraphiQL

If your Decidim instance has GraphiQL enabled, you can test the mutation interactively:

1. Navigate to `https://your-decidim-instance.com/api/graphiql`
2. Set the Authorization header with your token
3. Paste and execute your mutation

Example query for GraphiQL:

```graphql
mutation {
  component(id: "123") {
    ... on ProposalsMutation {
      createProposal(input: {
        attributes: {
          title: "Test Proposal from GraphiQL"
          body: "This is a test proposal created using GraphiQL interface to verify the API functionality."
        }
      }) {
        id
        title {
          translation(locale: "en")
        }
        publishedAt
      }
    }
  }
}
```
