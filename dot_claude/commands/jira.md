---
allowed-tools: all
description: Manage Jira issues, sprints, and project tasks efficiently
---

# Jira Management Command

**Default Configuration:**
- Username: tyler.vick.-nd@disney.com
- Default Project: IPT
- Default Board ID: 95
- Sprint Convention: "Engineering Sprint" is the default if multiple active sprints exist

## Usage Examples

Common usage patterns:
- `/jira status` - Check current sprint and your assigned issues
- `/jira create "Add user authentication" Task` - Create a new task in IPT project
- `/jira find "authentication"` - Search for issues containing "authentication"
- `/jira update PROJ-123 "In Progress"` - Transition an issue to a new status
- `/jira sprint` - View current sprint issues and progress
- `/jira my` - View all issues assigned to you

## Workflow Instructions

### 1. Sprint Status Check
When invoked with `status` or without arguments:
1. Get the current active sprint for board 95
2. Show sprint progress (dates, remaining days)
3. List my assigned issues in the current sprint with their status
4. Show any blocked or at-risk items
5. Display sprint burndown metrics if available

### 2. Issue Creation
When invoked with `create` or `new`:
1. Parse the description and issue type from the command
2. Use default project IPT unless specified
3. Auto-assign to me (tyler.vick.-nd@disney.com)
4. **Required Metadata:**
   - **task-category**: Set to "Planned" unless otherwise specified
   - **Components**: Always include "XR Tools" and "StudioShare"
   - **Type**: Default to "Task" or "Bug" depending on context
   - **Work Estimate**: Prompt for time estimate in format like "6h" (6 hours)
5. **Product-Specific Rules:**
   - **Exchange**: Parent ticket = IPT-3780, add "Exchange" component
   - **Core**: Parent ticket = IPT-3778, add "Core" component
6. **Sprint Assignment:**
   - If adding to current active sprint: Apply "fly-in" label
   - If adding to backlog: Add to inactive sprint (Exchange: 3777, Core: 3765)
7. Set appropriate priority based on keywords (urgent→High, bug→High, etc.)
8. Return the created issue key and URL

### 3. Issue Search
When invoked with `find`, `search`, or a search term:
1. Search across all accessible projects (unless filtered)
2. Use smart JQL construction:
   - Text search in summary and description
   - Include recently updated items
   - Show assignee, status, and priority
3. Display results in a concise table format
4. Limit to 10 results by default

### 4. Issue Updates
When invoked with `update` or an issue key:
1. If status name provided, transition the issue
2. Support common transitions: "In Progress", "Done", "Blocked", "Review"
3. Add a comment if additional text is provided
4. Update assignee if username/email is mentioned
5. Handle bulk updates for multiple issues

### 5. Sprint Management
When invoked with `sprint`:
1. Show current sprint for board 95
2. List all issues grouped by status
3. Highlight:
   - Issues without story points
   - Blocked items
   - Items in review
   - Recently completed items
4. Show team velocity if available

### 6. My Work View
When invoked with `my` or `mine`:
1. Show all my assigned issues across all projects
2. Group by project and priority
3. Highlight overdue items
4. Show issues in current sprint first
5. Include recently commented issues

### 7. Quick Actions
Support these quick patterns:
- `/jira close PROJ-123` - Transition to Done/Closed
- `/jira assign PROJ-123 user@email` - Reassign issue
- `/jira comment PROJ-123 "Status update"` - Add comment
- `/jira link PROJ-123 PROJ-456` - Link related issues
- `/jira epic PROJ-123` - Show all issues in epic
- `/jira board` - Show board 95 overview

### 8. Bulk Operations
When multiple issue keys are detected:
1. Confirm the operation before executing
2. Show progress as items are processed
3. Report success/failure for each item
4. Support transitions, assignments, and label updates

## Smart Behaviors

1. **Auto-Sprint Assignment**: When creating issues, automatically add to current active sprint
   - If there are multiple active sprints, "Engineering Sprint" should always be the default.
2. **Smart Status Mapping**: Map common status names to actual Jira transitions
3. **Issue Templates**: Detect patterns and suggest fields:
   - "bug" → Set type to Bug, priority to High
   - "spike" → Set type to Spike, add research label
   - "hotfix" → Set priority to Highest, add hotfix label

4. **Context Awareness**: 
   - Remember recently viewed issues for quick reference
   - Suggest related issues based on keywords
   - Auto-link to mentioned issue keys in descriptions

5. **Time Tracking**: If time estimates mentioned:
   - "2 hours" → Set remaining estimate
   - "spent 1h" → Log work with timesheet

## Error Handling

- If project not found: List available projects and ask for selection
- If transition invalid: Show available transitions for the issue
- If permissions denied: Explain what permissions are needed
- If sprint not found: List available sprints and ask for selection

## Output Format

Use concise, scannable output:
```
🎯 Current Sprint: Engineering Sprint 24 (5 days remaining)
📊 Your Issues (3):
  ✓ IPT-123 [Done] Implement user authentication
  🔄 IPT-124 [In Progress] Add password reset flow  
  ⚡ IPT-125 [To Do] Create user profile endpoint

💡 Tip: Use `/jira update IPT-125 "In Progress"` to start work
```

## Advanced Features

1. **JQL Support**: Accept raw JQL queries with `/jira jql "..."`
2. **Field Updates**: Support custom field updates with JSON syntax
3. **Bulk Import**: Create multiple issues from markdown lists
4. **Sprint Planning**: Move issues between sprints in bulk
5. **Release Management**: Create and manage fix versions
6. **Workflow Automation**: Chain multiple operations together

Remember to use the configured MCP Jira tools and respect the default configuration values!