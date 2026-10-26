---
name: thermo-nuclear-code-quality-review
description: "Use for thermo code-quality or maintainability-only reviews of a diff, including added wrappers, scattered branches, weak contracts, or broken module ownership. Use thermos for combined correctness and maintainability audits."
---

# Thermo-nuclear code quality review

Review implementation quality without changing files. This rubric judges maintainability, not CI status or release readiness.

## Scope

Review the requested diff and read surrounding code to establish ownership and caller constraints. Report problems introduced or worsened by the change, not unrelated existing debt.

For a generic thermo-nuclear or deep review without a narrower focus, use `skill://thermos`. For correctness or security alone, use `skill://thermo-nuclear-review`.

## Rubric

Prioritize structural regressions, concrete simplifications, branching growth, boundary damage, and then legibility.

### Delete complexity

Look for a behavior-preserving change that removes branches, wrappers, modes, helpers, or layers. Name the concrete alternative and explain what disappears. A speculative redesign or personal preference is not a finding.

### Keep flows cohesive

Trace new conditionals, one-off booleans, nullable modes, and scattered feature checks. Flag them when they split ownership or make a real flow harder to change safely. Prefer a simpler model over moving the same branches behind another wrapper.

### Respect canonical owners

Check for business rules in the wrong layer, feature logic in shared paths, duplicated canonical helpers, and implementation details leaking through APIs. Show the existing owner or helper that should hold the logic.

### Keep code direct

Question generic machinery hiding a simple data shape, identity wrappers, pass-through helpers, and refactors that add indirection without reducing concepts.

### Keep contracts explicit

Trace unnecessary optionality, unchecked casts, TypeScript `any` or `unknown`, Dart `dynamic`, and Rust `unsafe` without an established invariant. Flag silent fallbacks that hide malformed required data. Preserve validation and error handling when proposing a smaller alternative.

### Judge cohesion, not line counts

A size jump, including crossing 1,000 lines, prompts an ownership check. Size alone is not a blocker. Show mixed responsibilities, increased coupling, or a concrete change that has become harder to make before proposing decomposition.

### Check orchestration

Flag unnecessary sequential work or non-atomic related updates when the consequence and simpler structure are concrete. Parallelize only when doing so preserves ordering requirements and makes the flow clearer.

## Findings

Each finding must include:

- `file:line` in the changed code.
- Evidence of the structural problem and its likely six-month maintenance consequence.
- Priority and confidence, with assumptions stated.
- A smaller behavior-preserving alternative and the complexity it removes.

Keep high-conviction findings ahead of cosmetic nits. Separate blocking regressions from optional improvements. A simplification blocks only when the current design has a material maintenance cost and the proposed alternative demonstrably reduces it.

## Output

Return findings first, followed by a brief verdict and unchecked areas. If no material issues were found, say so without claiming exhaustive proof.

Keep the report in the response by default. Create summary and detail files only when requested or when the audit is too large for one readable response. This skill does not impose a report directory, line quota, or separate validation pipeline.
