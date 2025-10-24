# Implementation Summary: VoteProposal and UnvoteProposal GraphQL Mutations

## Overview
This PR successfully implements two new GraphQL mutations for the Decidim Proposals module:
- **VoteProposal**: Allows authenticated users to vote on proposals
- **UnvoteProposal**: Allows authenticated users to remove their vote from proposals

## Files Created

### Mutations
1. **decidim-proposals/lib/decidim/api/mutations/vote_proposal_type.rb**
   - GraphQL mutation for voting on proposals
   - Uses `VoteProposal` command
   - Handles `:ok` and `:invalid` broadcast events
   - Implements authorization check with `:vote` permission
   - Returns updated proposal with vote count

2. **decidim-proposals/lib/decidim/api/mutations/unvote_proposal_type.rb**
   - GraphQL mutation for removing votes from proposals
   - Uses `UnvoteProposal` command
   - Handles `:ok` broadcast event (command always succeeds)
   - Implements authorization check with `:unvote` permission
   - Returns updated proposal with vote count

### Tests
3. **decidim-proposals/spec/types/vote_proposal_type_spec.rb**
   - Comprehensive test suite for VoteProposalType
   - Tests success cases, authorization, duplicate votes, disabled voting, and maximum votes scenarios
   - 99 lines of test coverage

4. **decidim-proposals/spec/types/unvote_proposal_type_spec.rb**
   - Comprehensive test suite for UnvoteProposalType
   - Tests success cases, authorization, unvoting without prior vote, and disabled voting scenarios
   - 95 lines of test coverage

### Documentation
5. **decidim-proposals/GRAPHQL_VOTE_MUTATIONS.md**
   - Complete usage documentation with GraphQL query examples
   - Variable usage examples
   - Error handling documentation
   - Authorization requirements
   - 272 lines of comprehensive documentation

## Files Modified

### Configuration
6. **decidim-proposals/lib/decidim/proposals/api.rb**
   - Added autoload declarations for `VoteProposalType` and `UnvoteProposalType`

7. **decidim-proposals/lib/decidim/api/mutations/proposal_mutation_type.rb**
   - Registered `vote` field with VoteProposalType mutation
   - Registered `unvote` field with UnvoteProposalType mutation

### Translations
8. **decidim-proposals/config/locales/en.yml**
   - Added `proposal_votes.destroy.error` translation for unvote error messages

## Implementation Details

### Pattern Followed
- Based on existing `ProposalAnswerType` mutation pattern
- Uses existing `VoteProposal` and `UnvoteProposal` commands from proposal_votes_controller.rb
- Follows GraphQL mutation conventions in Decidim
- Implements proper authorization checks
- Uses I18n translations for error messages

### Key Features
- **Authorization**: Both mutations check permissions before execution
- **Error Handling**: Proper error handling with GraphQL::ExecutionError
- **Translations**: All error messages use I18n translations
- **Return Values**: Both mutations return the updated Proposal object
- **Vote Count**: Returned proposals include updated vote counts

### Commands Used
- **VoteProposal** (`decidim-proposals/app/commands/decidim/proposals/vote_proposal.rb`)
  - Creates a proposal vote
  - Handles maximum votes and temporary votes logic
  - Broadcasts `:ok` on success, `:invalid` on failure

- **UnvoteProposal** (`decidim-proposals/app/commands/decidim/proposals/unvote_proposal.rb`)
  - Destroys all votes from user on proposal
  - Updates temporary votes if needed
  - Always broadcasts `:ok`

## Usage Example

```graphql
# Vote for a proposal
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

# Remove vote from a proposal
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

## Testing
All tests follow the existing pattern from `proposal_mutation_type_spec.rb` and use:
- `include_context "with a graphql class mutation"`
- Various user types (normal user, unauthenticated user)
- Multiple scenarios for comprehensive coverage

## Code Review
All code review feedback has been addressed:
- Added missing translation for destroy error
- Removed unreachable `:invalid` handler in UnvoteProposalType
- Added explanatory comment for fallback error case
- Ensured consistent error handling pattern

## Statistics
- **Total Lines Added**: 543
- **New Files**: 5
- **Modified Files**: 3
- **Test Coverage**: 2 comprehensive spec files
- **Documentation**: Complete usage guide with examples

## Related Work
This implementation was informed by analyzing the following PRs:
- tremend-cofe/decidim-api#2
- decidim/decidim#14996
- decidim/decidim#14974
- decidim/decidim#14911
- decidim/decidim#14885
- decidim/decidim#14881
