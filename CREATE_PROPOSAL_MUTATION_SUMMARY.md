# CreateProposal Mutation - Implementation Summary

This document summarizes the new CreateProposal GraphQL mutation implementation for the Decidim API.

## What Was Created

### 1. Core Mutation Files

#### `decidim-proposals/lib/decidim/api/mutations/create_proposal_type.rb`
The main mutation class that:
- Extends `Decidim::Api::Types::BaseMutation` (follows Relay conventions)
- Accepts proposal attributes (title, body, address, coordinates, taxonomies)
- Uses the existing `Decidim::Proposals::CreateProposal` command
- Retrieves component from GraphQL context
- Validates user permissions
- Returns created proposal or error

#### `decidim-proposals/lib/decidim/api/mutations/create_proposal_attributes.rb`
Input object defining the mutation parameters:
- `title` (String, required) - 15-150 characters
- `body` (String, required) - minimum 15 characters
- `address` (String, optional)
- `latitude` (Float, optional)
- `longitude` (Float, optional)
- `taxonomy_ids` (Array of IDs, optional)

### 2. Integration Updates

#### `decidim-proposals/lib/decidim/api/mutations/proposals_mutation_type.rb`
Added field:
```ruby
field :create_proposal, mutation: Decidim::Proposals::CreateProposalType, 
      description: "Creates a proposal"
```

#### `decidim-proposals/lib/decidim/proposals/api.rb`
Registered autoload for:
- `CreateProposalType`
- `CreateProposalAttributes`

### 3. Tests

#### `decidim-proposals/spec/types/create_proposal_type_spec.rb`
Comprehensive test coverage:
- ✅ Admin user can create proposals
- ✅ Normal user can create proposals
- ✅ API user can create proposals
- ✅ Proposals with taxonomies
- ✅ Authorization checks (creation disabled)
- ✅ Validation errors (invalid title, body, missing required fields)
- ✅ Unauthenticated requests are rejected

### 4. Documentation

#### `decidim-proposals/lib/decidim/api/mutations/CREATE_PROPOSAL_MUTATION_USAGE.md`
Complete usage guide with:
- GraphQL schema definition
- Input type documentation
- 4 detailed examples with expected responses
- Authentication requirements
- Permission checks
- Error handling guide
- Important notes about draft status, content processing, etc.

#### `decidim-proposals/lib/decidim/api/mutations/CREATE_PROPOSAL_EXAMPLES.md`
Practical implementation examples:
- cURL examples (basic and complete)
- JavaScript/TypeScript (Fetch API and Apollo Client)
- Python (with requests library)
- Ruby (with net/http)
- OAuth authentication setup guide
- Error handling examples
- GraphiQL testing instructions

## How to Use

### Basic Example

```graphql
mutation {
  component(id: "123") {
    ... on ProposalsMutation {
      createProposal(input: {
        attributes: {
          title: "Improve Public Transportation"
          body: "We need to expand bus routes to underserved neighborhoods."
        }
      }) {
        id
        title { translation(locale: "en") }
        publishedAt
      }
    }
  }
}
```

### With All Fields

```graphql
mutation {
  component(id: "123") {
    ... on ProposalsMutation {
      createProposal(input: {
        attributes: {
          title: "Install Bike Lanes on Main Street"
          body: "We propose adding dedicated bike lanes..."
          address: "Main Street, Barcelona, Spain"
          latitude: 41.3851
          longitude: 2.1734
          taxonomyIds: ["789", "790"]
        }
      }) {
        id
        title { translation(locale: "en") }
        address
        taxonomies {
          id
          name { translation(locale: "en") }
        }
      }
    }
  }
}
```

## Authentication

Requires OAuth token with scopes:
- `api:read` - Read access
- `api:write` - Write access (required for mutations)

Example:
```bash
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" ...
```

## Key Features

1. **Follows Existing Patterns**: Based on `ProposalAnswerType` mutation structure
2. **Uses Existing Command**: Leverages `CreateProposal` command from `ProposalsController`
3. **Full Validation**: All form validations from `ProposalForm` are applied
4. **Permission Checks**: Ensures user has permission to create proposals
5. **Draft Status**: Created proposals are drafts (not published) initially
6. **Taxonomy Support**: Can associate proposals with taxonomies/categories
7. **Geocoding Support**: Optional address and coordinates
8. **Content Processing**: Title and body are processed for inline images and sanitized

## Technical Details

### Design Decisions

1. **Component from Context**: The mutation retrieves the component from GraphQL context (via `object` parameter) rather than requiring it as an argument. This follows the pattern where mutations are accessed through `component(id)` query.

2. **Relay Conventions**: Extends `BaseMutation` which uses GraphQL Relay classic mutations. Arguments are automatically wrapped in an `input` object.

3. **Error Handling**: Returns `GraphQL::ExecutionError` for validation errors, which get caught by the test context and raised as StandardError.

4. **Permissions**: Uses `allowed_to?(:create, :proposal, ...)` to check if user can create proposals in the component.

### File Structure

```
decidim-proposals/
├── lib/
│   └── decidim/
│       ├── api/
│       │   └── mutations/
│       │       ├── create_proposal_type.rb          # Main mutation
│       │       ├── create_proposal_attributes.rb    # Input object
│       │       ├── proposals_mutation_type.rb       # Updated with new field
│       │       ├── CREATE_PROPOSAL_MUTATION_USAGE.md
│       │       └── CREATE_PROPOSAL_EXAMPLES.md
│       └── proposals/
│           └── api.rb                                # Updated with autoload
└── spec/
    └── types/
        └── create_proposal_type_spec.rb              # Tests
```

## Testing

Run the spec:
```bash
cd decidim-proposals
bundle exec rspec spec/types/create_proposal_type_spec.rb
```

## References

This implementation was inspired by:
- Decidim PRs: #14996, #14974, #14911, #14885, #14881
- `ProposalAnswerType` mutation pattern
- `ProposalAnswersController#create` method
- `ProposalsController#create` method and `CreateProposal` command

## Next Steps

1. ✅ Code review completed
2. 🔄 Merge PR when approved
3. 📝 Update API changelog
4. 📚 Add to Decidim API documentation
5. 🧪 Test in development/staging environment
6. 🚀 Deploy to production

## Support

For questions or issues:
- See detailed documentation in `CREATE_PROPOSAL_MUTATION_USAGE.md`
- Check practical examples in `CREATE_PROPOSAL_EXAMPLES.md`
- Review the spec file for test cases
- Consult existing `ProposalAnswerType` for similar patterns
