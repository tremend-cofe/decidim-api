# Decidim Proposals GraphQL Mutations

This directory contains the GraphQL mutation types for the Decidim Proposals module.

## Available Mutations

### 1. ProposalAnswerType (`proposal_answer_type.rb`)
Allows administrators to answer proposals with a status (accepted, rejected, or evaluating).

**Usage:**
```graphql
mutation {
  proposals {
    proposal(id: "123") {
      answer(input: { attributes: { state: "accepted", answerContent: {...} } }) {
        id
        state
        answer { translation(locale: "en") }
      }
    }
  }
}
```

### 2. UpdateProposalType (`update_proposal_type.rb`)
Allows proposal authors (and admins) to update their proposals.

**Usage:**
```graphql
mutation {
  proposals {
    proposal(id: "123") {
      update(input: { attributes: { title: "...", body: "..." } }) {
        id
        title { translation(locale: "en") }
        body { translation(locale: "en") }
      }
    }
  }
}
```

## Input Types

- `AnswerProposalAttributes` (`answer_proposal_attributes.rb`) - Input schema for answering proposals
- `UpdateProposalAttributes` (`update_proposal_attributes.rb`) - Input schema for updating proposals

## Registration

Mutations are registered in:
- `ProposalMutationType` (`proposal_mutation_type.rb`) - Individual proposal mutations
- `ProposalsMutationType` (`proposals_mutation_type.rb`) - Component-level mutations

And autoloaded in:
- `decidim-proposals/lib/decidim/proposals/api.rb`

## Testing

Each mutation has corresponding spec files in:
- `decidim-proposals/spec/types/`
- `decidim-proposals/spec/shared/` (for shared examples)

## Documentation

For detailed usage examples and API reference:
- See `decidim-proposals/USAGE_UPDATE_PROPOSAL_MUTATION.md` for UpdateProposal mutation
- Check the main Decidim API documentation at https://docs.decidim.org/
