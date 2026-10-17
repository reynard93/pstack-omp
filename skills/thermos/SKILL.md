---
name: thermos
description: "Launch both thermo-nuclear reviews in parallel on the judge seat, then synthesize their findings. Use for thermos, double thermo review, or combined bug/security and code-quality branch audits."
---

# Thermos

Run the two thermo review passes as parallel subagents, then synthesize their results.

## Workflow

1. Determine the review scope from the user request, PR, current branch, or relevant changed files.
2. Gather the diff (`git diff <base>...HEAD`, default base `main`) and the full contents of the changed files, so reviewers evaluate the change without guessing. For a large file set, gather contents with a `scout`.
3. Launch both reviewers in one `task` call, two `tasks[]` items, each with `agent: pstack-judge`. Seat models come from `/skill:setup-pstack`.
   - Item 1 brief: "Read `skill://thermo-nuclear-review` and follow it as your complete rubric." Covers bugs, breakages, security, devex regressions, feature-flag leaks, and other branch-audit risks.
   - Item 2 brief: "Read `skill://thermo-nuclear-code-quality-review` and follow it as your complete rubric." Covers maintainability, structure, file-size growth, spaghetti, abstractions, and codebase-health risks.
   - Put the shared material in `context`: the scope, `### Git / diff output`, `### Changed file contents`, and "Read-only: do not edit files or run mutating commands. Return prioritized findings with file:line evidence. Do not spawn subagents."
4. After both finish, synthesize the results with findings first, deduplicated across reviewers. Weight overlapping findings more heavily, resolve disagreements with your own judgment, and keep summaries brief.

Do not restate each reviewer's report wholesale. Surface the unified verdict, the highest-signal findings, and any remaining uncertainty.
