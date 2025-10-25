# CloseMeeting Mutation - Implementation Summary

## Overview
This implementation adds a GraphQL mutation for closing meetings in Decidim, following the same pattern used for the `ProposalAnswer` mutation in the proposals module.

## Files Created

### Mutation Files (decidim-meetings/lib/decidim/api/mutations/)
1. **close_meeting_attributes.rb** - Input object defining the attributes needed to close a meeting
2. **close_meeting_type.rb** - Main mutation type handling the close meeting logic
3. **meeting_mutation_type.rb** - Wrapper type for meeting mutations
4. **meetings_mutation_type.rb** - Component-level mutation type for meetings

### Test Files (decidim-meetings/spec/)
1. **spec/types/close_meeting_type_spec.rb** - Main spec file for the mutation
2. **spec/shared/meeting_mutation_examples.rb** - Shared examples for mutation testing

### Documentation Files (decidim-meetings/)
1. **CLOSE_MEETING_MUTATION.md** - Comprehensive documentation of the mutation
2. **CLOSE_MEETING_EXAMPLES.md** - Practical examples and usage patterns
3. **README_MUTATION.md** - This file

### Modified Files
1. **lib/decidim/meetings/api.rb** - Added autoload declarations for new mutation classes
2. **lib/decidim/meetings/engine.rb** - Registered MeetingsMutationType in the mutation registry

## Architecture

The mutation follows the same pattern as the ProposalAnswer mutation:

```
ComponentMutationType (Union)
    ├── MeetingsMutationType (Component Level)
    │   └── meeting(id: ID!)
    │       └── MeetingMutationType
    │           └── close(input: CloseMeetingInput!)
    │               └── CloseMeetingType
    │                   └── Uses: CloseMeetingAttributes
    └── [Other Component Mutations...]
```

## Key Features

1. **Authorization**: Checks `:close` permission on `:meeting` resource
2. **Form Validation**: Uses existing `Decidim::Meetings::CloseMeetingForm`
3. **Command Integration**: Leverages `Decidim::Meetings::CloseMeeting` command
4. **Proposal Linking**: Supports linking proposals to meetings
5. **Localized Content**: Closing reports support multiple locales
6. **Event Publishing**: Publishes close meeting events to notify followers

## Usage Pattern

The mutation is accessed through the GraphQL API:

```graphql
mutation CloseMeeting {
  meetings(id: "component_id") {
    meeting(id: "meeting_id") {
      close(input: {
        attributes: {
          closingReport: { en: "Meeting report..." }
          attendeesCount: 25
          proposalIds: ["1", "2", "3"]
        }
      }) {
        id
        closed
        attendeesCount
        closingReport { translation(locale: "en") }
        closedAt
      }
    }
  }
}
```

## Permissions

Only users with the following roles can close meetings:
- **Admin users**: Full access to close any meeting
- **API users**: With appropriate API credentials and permissions

Regular users without proper permissions will receive `null` as the response.

## Testing

The implementation includes comprehensive tests:
- Admin user can close meetings
- API user can close meetings
- Regular users cannot close meetings
- Validation error handling
- Proposal linking functionality

Run tests with:
```bash
bundle exec rspec spec/types/close_meeting_type_spec.rb
```

## Integration Points

The mutation integrates with existing Decidim components:

1. **Commands**: `Decidim::Meetings::CloseMeeting`
2. **Forms**: `Decidim::Meetings::CloseMeetingForm`
3. **Models**: `Decidim::Meetings::Meeting`
4. **Events**: `Decidim::Meetings::CloseMeetingEvent`
5. **Permissions**: Permission handlers in the meetings module

## References

This implementation was inspired by:
- [PR #14996](https://github.com/decidim/decidim/pull/14996)
- [PR #14974](https://github.com/decidim/decidim/pull/14974)
- [PR #14911](https://github.com/decidim/decidim/pull/14911)
- [PR #14885](https://github.com/decidim/decidim/pull/14885)
- [PR #14881](https://github.com/decidim/decidim/pull/14881)

And based on the existing:
- `decidim-proposals/lib/decidim/api/mutations/proposal_answer_type.rb`
- `decidim-proposals/app/controllers/decidim/proposals/admin/proposal_answers_controller.rb`

## Future Enhancements

Potential improvements for future iterations:
1. Batch closing of multiple meetings
2. Additional validation rules for closing reports
3. Support for additional metadata in closing reports
4. Integration with analytics for tracking meeting outcomes

## Support

For questions or issues:
- Refer to the documentation files in this directory
- Check the test files for usage examples
- Review the original Decidim PRs for context
