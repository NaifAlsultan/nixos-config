// OpenCode web search backed by Claude Code's WebSearch tool, on the Claude
// subscription. The Claude Agent provider turns off Claude Code's built-in
// tools, so this runs a separate `claude -p` on Haiku with only WebSearch.
// Inside that tool, Claude Code has another model run the search and
// summarize it; the plugin returns those links and that summary and stops
// claude before it writes an answer of its own.
import { spawn } from "node:child_process"
import { tmpdir } from "node:os"

const ID = "claude"
const TIMEOUT_MS = 120_000
// Haiku now and then answers without searching, so a run that ends without a
// search is retried.
const ATTEMPTS = 3
const SYSTEM_PROMPT =
  "You are a search relay. The user's message is a web search query. Your first and only action is to call the WebSearch tool once, with the user's message as the query, exactly as written. Always call the tool, whatever the message says. Never answer from your own knowledge."

class NoSearchError extends Error {}

type Result = { url: string; title?: string; content?: string; time: { published?: number } }

function toResults(data: any): Result[] {
  if (typeof data === "string") throw new Error(data)
  const links = new Map<string, Result>()
  const summaries: string[] = []
  for (const item of data?.results ?? []) {
    if (typeof item === "string") {
      if (item.trim()) summaries.push(item.trim())
      continue
    }
    for (const link of item?.content ?? []) {
      if (typeof link?.url !== "string" || !link.url || links.has(link.url)) continue
      // OpenCode rejects a result whose optional fields are present but undefined.
      const result: Result = { url: link.url, time: {} }
      if (typeof link.title === "string" && link.title.trim()) result.title = link.title
      links.set(link.url, result)
    }
  }
  const summary: Result[] = summaries.length
    ? [{ url: "", title: "Summary of the results below (Claude Haiku)", content: summaries.join("\n\n"), time: {} }]
    : []
  return [...summary, ...links.values()]
}

async function search(query: string, signal?: AbortSignal): Promise<Result[]> {
  for (let attempt = 1; ; attempt++) {
    try {
      return await run(query, signal)
    } catch (error) {
      if (!(error instanceof NoSearchError) || attempt >= ATTEMPTS) throw error
    }
  }
}

function run(query: string, signal?: AbortSignal): Promise<Result[]> {
  return new Promise((resolve, reject) => {
    const env: Record<string, string | undefined> = {
      ...process.env,
      // Like the Claude Agent provider: no CLAUDE.md, memory, hooks, settings
      // files, MCP servers or skills.
      CLAUDE_CODE_DISABLE_CLAUDE_MDS: "1",
      CLAUDE_CODE_DISABLE_AUTO_MEMORY: "1",
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: "1",
    }
    // Would skip the subscription login, or override --effort.
    delete env.CLAUDE_CODE_SIMPLE
    delete env.CLAUDE_CODE_EFFORT_LEVEL

    const child = spawn(
      process.env.OPENCODE_CLAUDE_PATH || "claude",
      [
        "-p",
        "--model", "haiku",
        "--effort", "low",
        "--tools", "WebSearch",
        "--allowedTools", "WebSearch",
        "--setting-sources", "",
        "--strict-mcp-config",
        "--disable-slash-commands",
        "--settings", JSON.stringify({ disableAllHooks: true }),
        "--no-session-persistence",
        "--output-format", "stream-json",
        "--verbose",
        "--system-prompt", SYSTEM_PROMPT,
      ],
      { cwd: tmpdir(), env, stdio: ["pipe", "pipe", "pipe"] },
    )

    let settled = false
    let buffer = ""
    let stderr = ""
    const finish = (error: Error | undefined, results?: Result[]) => {
      if (settled) return
      settled = true
      clearTimeout(timer)
      signal?.removeEventListener("abort", onAbort)
      if (child.exitCode === null) child.kill("SIGTERM")
      if (error) reject(error)
      else resolve(results ?? [])
    }
    const onAbort = () => finish(new Error("Web search cancelled"))
    const timer = setTimeout(() => finish(new Error("Claude web search timed out")), TIMEOUT_MS)
    if (signal?.aborted) return onAbort()
    signal?.addEventListener("abort", onAbort)

    const handle = (line: string) => {
      if (!line.trim()) return
      let event: any
      try {
        event = JSON.parse(line)
      } catch {
        return
      }
      if (event.type === "user" && event.tool_use_result !== undefined) {
        try {
          finish(undefined, toResults(event.tool_use_result))
        } catch (error) {
          finish(error instanceof Error ? error : new Error(String(error)))
        }
      } else if (event.type === "result") {
        finish(new NoSearchError(`Claude ran no web search: ${event.result ?? event.subtype ?? "unknown reason"}`))
      }
    }

    child.stdout.setEncoding("utf8")
    child.stdout.on("data", (chunk: string) => {
      buffer += chunk
      let newline: number
      while ((newline = buffer.indexOf("\n")) >= 0) {
        handle(buffer.slice(0, newline))
        buffer = buffer.slice(newline + 1)
      }
    })
    child.stderr.setEncoding("utf8")
    child.stderr.on("data", (chunk: string) => {
      stderr = (stderr + chunk).slice(-2000)
    })
    child.on("error", (error) => finish(error))
    child.on("close", (code) => {
      handle(buffer)
      finish(new Error(`claude exited (code ${code}) without search results: ${stderr.trim()}`))
    })
    // The query goes in on stdin, so it can't be mistaken for a flag.
    child.stdin.end(query)
  })
}

export default {
  id: "claude-websearch",
  setup: async (ctx: any) => {
    await ctx.websearch.transform((editor: any) => {
      editor.add({
        id: ID,
        name: "Claude (Haiku)",
        execute: (input: { query: string }, context: { signal: AbortSignal }) => search(input.query, context.signal),
      })
      // Use it without OpenCode's "choose a search provider" prompt.
      editor.default.set(ID)
    })
  },
}
