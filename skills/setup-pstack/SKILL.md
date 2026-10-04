---
name: setup-pstack
description: Configure which models pstack's subagent seats use and at what reasoning budget. Detects your available models with `omp models` and writes seat model roles plus agent overrides to omp config. Use for /skill:setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

pstack spawns its subagents through five model seats. Each seat is an omp model role. Each pstack agent points at its seat through `task.agentModelOverrides`. This skill picks a model per seat and writes both into the global omp config (`~/.omp/agent/config.yml`).

| Seat (model role) | Agents on the seat | Used for |
|---|---|---|
| `pstack-code` | `poteto-agent`, `pstack-code` | code delegates (feature, refactoring, bug fix, perf, hillclimb), how explorers, why investigators, swarm workers |
| `pstack-judge` | `poteto-agent-deep`, `pstack-judge` | the hardest changes, judgment and prose, how explainers, why synthesizers, reflect reviewers |
| `pstack-panel-a` | `pstack-panel-a` | panel seat 1 for arena, architect, and interrogate; cross-judge candidate |
| `pstack-panel-b` | `pstack-panel-b` | panel seat 2 for the same; reflect tooling lens |
| `pstack-panel-c` | `pstack-panel-c` | panel seat 3 for the same |

An unset seat runs on the parent session's model. That is how a user who wants every subagent on their session model opts out. `comment-sicko` always runs on the parent model.

## Steps

### 1. Detect available models

Run `omp models --json`. Use the entries in `.models[]` whose `kind` is `chat`. Each entry has a `selector` (`provider/id`) and `thinking` (the supported effort levels, or `null`). That list is the dependable source. Never write a selector you have not seen in it. If the list is empty, ask the user to log in (`/login`) and stop.

### 2. Load current state

Run `omp config get modelRoles --json` and `omp config get task.agentModelOverrides --json`. The current seat values are the `pstack-*` keys of `modelRoles`. A pstack agent whose override points somewhere other than its seat alias (`@pstack-<seat>`) is a user customization. Keep it and mention it in step 3.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Use the `ask` tool with these four options, and name the current budget when every configured seat shares one effort suffix.

- `unlimited (max effort)`
- `large (xhigh effort)`
- `medium (high effort)`
- `small (medium effort)`

**(b) Build the working table.** On a re-run, start from the current seat values. On a first run, start from these defaults, each resolved against the detected list:

- `pstack-judge` and `pstack-panel-a`: the newest Claude Opus.
- `pstack-panel-b`: the newest GPT flagship (for example a `gpt-5.6-sol` model).
- `pstack-code` and `pstack-panel-c`: the newest Grok reasoning model. With no Grok, use the newest Gemini Pro for `pstack-panel-c` and the newest GPT codex model for `pstack-code`.

When several providers serve the same model, prefer the vendor's own provider (`anthropic/`, `openai/` or `openai-codex/`, `xai/` or `xai-oauth/`, `google/`) over a reseller. If a default family is missing, pick the strongest detected model from a family not already on the panel, so the three panel seats stay on three families when possible.

Then apply the budget's effort to every seat. The target is `max`, `xhigh`, `high`, or `medium`. Append `:<level>` when the model's `thinking` list contains the target. Otherwise use the highest level in its list below the target. A model with `thinking: null` gets no suffix. An unset seat stays unset.

**(c) Show the seats and confirm.** Show every seat with its agents and model, plus any custom override from step 2. Use `ask` with `multi: true` to ask which seats to change, with an "accept as shown" option. For each seat the user picks, ask again with up to five detected candidates plus `unset (follow the session model)`. Keep the panel on distinct families unless the user chooses otherwise. A second opinion is only worth its cost on a different model.

### 4. Validate

Every selector you will write must be in the detected list, and its suffix must be in that model's `thinking` list. If a chosen value fails, stop and ask again.

### 5. Write the config

Run the bundled script with one `seat=value` pair per seat. Pass `unset` to clear a seat.

```bash
"$(realpath skill://setup-pstack)/scripts/apply-seats.sh" \
  pstack-code=<selector:level> pstack-judge=<selector:level> \
  pstack-panel-a=<selector:level> pstack-panel-b=<selector:level> pstack-panel-c=<selector:level>
```

The script reads both records, sets `modelRoles.pstack-<seat>` and points the seat's agents at `@pstack-<seat>`, and writes the records back with `omp config set`. It keeps every non-pstack key. For `unset` it deletes the role and only the overrides that still point at that seat. Re-running it with the same pairs is a no-op, so re-runs stay idempotent. It needs `jq`.

If `omp config set` reports that another source overrides a key (a project `.omp/config.yml`, an overlay, or an environment variable), tell the user which one, since the global value will not take effect there.

### 6. Confirm

Tell the user what was written. The next spawn picks it up, since task preflight reloads settings. No restart is needed. Seats can also be changed later in `/model` (Roles view, roles `pstack-*`) or per agent in the `/agents` hub. Re-running this skill updates them.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill under `.omp/skills/`, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /skill:create-verification-skill." On yes, read `skill://create-verification-skill` and follow it. On no, move on without pushing.
