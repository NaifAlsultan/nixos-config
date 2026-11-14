---
name: OpenCode sessions
description: Find and read previous OpenCode sessions. Use when the user gives a session ID (ses_...) or refers to an earlier session.
---

List sessions across all projects, newest first. Add `--param search=<word>` to filter by title:

```sh
opencode api session.list --param limit=100 | jq -r '.data[] | "\(.id)  \(.title)"'
```

To read a session, export it to a file and search it with `rg`. Don't print the whole file, because it can be megabytes:

```sh
opencode session export <id> > /tmp/<id>.json
rg -n 'pattern' /tmp/<id>.json
```

Subagents run in separate sessions that the export doesn't include. List them with `--param parentID=<id>`.

Don't read OpenCode's database or files under `~/.local/share/opencode`.
