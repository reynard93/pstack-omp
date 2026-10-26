---
name: thermos
description: "Use for thermos, double thermo, generic thermo-nuclear or deep branch reviews, and combined correctness, security, and maintainability audits. Run two focused reviewers and synthesize one verdict."
---

# Thermos

Run correctness and maintainability reviews in parallel, then return one evidence-backed verdict.

## Route

Use this workflow for a generic thermo-nuclear or deep review and for combined audits. If the user requests only correctness or security, use `skill://thermo-nuclear-review` directly. If the user requests only code quality or maintainability, use `skill://thermo-nuclear-code-quality-review` directly.

## Workflow

1. Establish the requested scope and base. Include working-tree changes when requested. For a branch review, use `git diff <base>...HEAD`, with `main` as the default base.
2. Gather the diff and relevant changed-file contents. Put large shared material in a local artifact and pass its path to reviewers. Give reviewers repository access to trace callers and dependencies beyond the diff.
3. Launch both reviewers in one `task` call with two `tasks[]` items, each using `agent: pstack-judge`. Seat models come from `skill://setup-pstack`.
   - Correctness brief: "Read `skill://thermo-nuclear-review` and apply its audit rubric to the supplied scope."
   - Maintainability brief: "Read `skill://thermo-nuclear-code-quality-review` and apply its maintainability rubric to the supplied scope."
   - Shared context must include the scope, base, artifact paths, repository path, and these constraints: "You are a subagent. Don't run memo. Review only the assigned rubric; the parent already selected the combined workflow. Read-only. Do not edit files, run mutating commands, or spawn subagents. Return prioritized findings with file:line evidence and unchecked areas."
4. Complete both reviews before synthesis. If a reviewer fails, report missing coverage instead of presenting a completed combined audit.
5. Deduplicate findings and resolve disagreements against the code. Weight reproductions, traced paths, and violated invariants, not the number of reviewers who agree.
6. Return findings first, then a brief unified verdict and unchecked areas. Separate blocking issues from optional simplifications. Preserve attribution for findings sourced from PR comments or bots.

Keep the result in the response by default. Retain detailed report files only when requested or needed for a large audit. Do not repeat both reviewer reports wholesale.
