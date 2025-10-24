# VoteProposal and UnvoteProposal GraphQL Mutations

This document provides examples on how to use the `VoteProposal` and `UnvoteProposal` GraphQL mutations.

## Overview

These mutations allow authenticated users to vote and unvote on proposals in Decidim.

- **VoteProposal**: Adds a vote to a proposal
- **UnvoteProposal**: Removes a vote from a proposal

## Prerequisites

- User must be authenticated
- Proposal voting must be enabled in the component settings
- User must have permission to vote on proposals

## Usage Examples

### 1. Vote for a Proposal

To vote for a proposal, you need to:
1. Query the proposals mutation type with the proposal ID
2. Call the `vote` mutation on that proposal

```graphql
mutation {
  proposals {
    proposal(id: "123") {
      vote {
        id
        voteCount
        title {
          translation(locale: "en")
        }
      }
    }
  }
}
```

**Expected Response (Success):**
```json
{
  "data": {
    "proposals": {
      "proposal": {
        "vote": {
          "id": "123",
          "voteCount": 5,
          "title": {
            "translation": "My Proposal Title"
          }
        }
      }
    }
  }
}
```

**Expected Response (Error - Already Voted):**
```json
{
  "data": {
    "proposals": {
      "proposal": {
        "vote": null
      }
    }
  },
  "errors": [
    {
      "message": "There was a problem voting the proposal.",
      "path": ["proposals", "proposal", "vote"]
    }
  ]
}
```

### 2. Remove Vote from a Proposal

To remove your vote from a proposal:

```graphql
mutation {
  proposals {
    proposal(id: "123") {
      unvote {
        id
        voteCount
        title {
          translation(locale: "en")
        }
      }
    }
  }
}
```

**Expected Response (Success):**
```json
{
  "data": {
    "proposals": {
      "proposal": {
        "unvote": {
          "id": "123",
          "voteCount": 4,
          "title": {
            "translation": "My Proposal Title"
          }
        }
      }
    }
  }
}
```

### 3. Query Proposal with Vote Information

You can query a proposal to check if you have voted and get the current vote count:

```graphql
query {
  proposals {
    proposal(id: "123") {
      id
      title {
        translation(locale: "en")
      }
      voteCount
      body {
        translation(locale: "en")
      }
    }
  }
}
```

### 4. Complete Example with Variables

Using variables for better code reusability:

```graphql
mutation VoteForProposal($proposalId: ID!) {
  proposals {
    proposal(id: $proposalId) {
      vote {
        id
        voteCount
        state
      }
    }
  }
}
```

With variables:
```json
{
  "proposalId": "123"
}
```

### 5. Unvote with Variables

```graphql
mutation UnvoteProposal($proposalId: ID!) {
  proposals {
    proposal(id: $proposalId) {
      unvote {
        id
        voteCount
        state
      }
    }
  }
}
```

With variables:
```json
{
  "proposalId": "123"
}
```

## Error Handling

### Common Errors

1. **Unauthorized**: User is not authenticated
   ```json
   {
     "data": {
       "proposals": {
         "proposal": {
           "vote": null
         }
       }
     }
   }
   ```

2. **Already Voted**: User has already voted for this proposal
   ```json
   {
     "errors": [
       {
         "message": "There was a problem voting the proposal."
       }
     ]
   }
   ```

3. **Voting Disabled**: Component settings disable voting
   ```json
   {
     "data": {
       "proposals": {
         "proposal": {
           "vote": null
         }
       }
     }
   }
   ```

4. **Maximum Votes Reached**: Proposal has reached maximum votes
   ```json
   {
     "errors": [
       {
         "message": "There was a problem voting the proposal."
       }
     ]
   }
   ```

## Authorization

These mutations require:
- Authentication: User must be logged in
- Permission: User must have `:vote` or `:unvote` permission on the proposal

## Implementation Details

- **Vote Command**: Uses `Decidim::Proposals::VoteProposal` command
- **Unvote Command**: Uses `Decidim::Proposals::UnvoteProposal` command
- **Pattern**: Follows the same pattern as `ProposalAnswerType` mutation
- **Location**: Mutations are in `decidim-proposals/lib/decidim/api/mutations/`

## Testing

The mutations are tested in:
- `decidim-proposals/spec/types/vote_proposal_type_spec.rb`
- `decidim-proposals/spec/types/unvote_proposal_type_spec.rb`

Tests cover:
- Successful vote/unvote operations
- Unauthorized access
- Duplicate votes
- Voting when disabled
- Maximum votes reached scenarios

## Related Files

- Mutation: `decidim-proposals/lib/decidim/api/mutations/vote_proposal_type.rb`
- Mutation: `decidim-proposals/lib/decidim/api/mutations/unvote_proposal_type.rb`
- Command: `decidim-proposals/app/commands/decidim/proposals/vote_proposal.rb`
- Command: `decidim-proposals/app/commands/decidim/proposals/unvote_proposal.rb`
- Controller: `decidim-proposals/app/controllers/decidim/proposals/proposal_votes_controller.rb`
