---
name: OpenCode sessions
description: Find and read previous OpenCode sessions. Use when the user gives a session ID (ses_...) or refers to an earlier session.
---

Use the `opencode` CLI for sessions. Don't read OpenCode's database or files under `~/.local/share/opencode`. Only read: don't delete, import, or prompt other sessions. The current session's ID is in `$OPENCODE_SESSION_ID`.

## Find a session

```sh
opencode api session.list --param limit=100 | jq -r '.data[] | "\(.id)  \(.location.directory)  \(.title)"'
```

- Results cover all projects, newest first. `opencode session list` shows only the current project.
- `--param search=<word>` filters by title only, as an exact substring, ignoring case. `agent browser` doesn't match `agent-browser`, so search for one distinctive word. Message text isn't searched.
- `--param directory=/absolute/path` limits results to one directory.
- Results include subagent sessions. `--param parentID=null` returns top-level sessions only.
- `opencode api session.get --param sessionID=<id>` returns one session's title, directory, and `parentID`.

## Read the latest messages

To see how a session ended, you don't need to export it:

```sh
opencode api session.message.list --param sessionID=<id> --param order=desc --param limit=1 --param type=assistant \
  | jq -r '.data[].content[] | select(.type == "text") | .text'
```

Use `--param type=user` with `jq -r '.data[].text'` to see the user's latest message.

## Read or search a whole session

Export it to a file. Don't print the file whole, because it can be megabytes:

```sh
opencode session export <id> > /tmp/<id>.json
```

Search it with `rg`. Tool output makes some lines thousands of characters long, so cap them:

```sh
rg -n -i -M 200 --max-columns-preview 'pattern' /tmp/<id>.json
```

To read the conversation, extract the user and assistant text into a file a fraction of the export's size, then read or search that file:

```sh
jq -r '.messages[] | if .type == "user" then "## user\n\(.text)\n" elif .type == "assistant" then (.content[] | select(.type == "text") | "## assistant\n\(.text)\n") else empty end' /tmp/<id>.json > /tmp/<id>.txt
```

For a long session, read the user messages first to get its outline:

```sh
jq -r '.messages[] | select(.type == "user") | .text' /tmp/<id>.json
```

List the tool calls and their inputs:

```sh
jq -c '.messages[] | select(.type == "assistant") | .content[] | select(.type == "tool") | {name, status: .state.status, input: .state.input}' /tmp/<id>.json
```

## Export format

`{"info": {...}, "messages": [...]}`, with messages oldest first. `.info` holds `id`, `title`, `parentID`, and `location.directory`. Each message has `id`, `type`, and `time.created` (Unix milliseconds).

- `user`: the text is in `.text`.
- `assistant`: `.content` is a list of parts. `text` and `reasoning` parts have `.text`. A `tool` part has `.name`, `.state.status`, `.state.input`, and output in `.state.content[].text`. When `.state.status` is `error`, the reason is in `.state.error.message`.
- `synthetic`: injected text in `.text`. A subagent's final report has `.metadata.source == "subagent"` and the child's ID in `.metadata.childID`.
- `system` (instruction notices) and `idle` (end of a turn) are rarely useful.

## Subagents

Each subagent runs in its own session, and the parent's export doesn't include it. The parent only contains the subagent's prompt (the `subagent` tool's input) and its final report (the `synthetic` message). List the children, then export them like any other session:

```sh
opencode api session.list --param parentID=<id> | jq -r '.data[] | "\(.id)  \(.title)"'
```
