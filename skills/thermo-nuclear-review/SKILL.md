---
name: thermo-nuclear-review
description: "Use for thermo correctness-only or security-only audits of a diff, covering broken behavior, developer setup regressions, and feature-gate leaks. Use thermos for combined correctness and maintainability audits."
---

# Thermo-nuclear correctness and security review

Audit the requested change for bugs, breaking behavior, security vulnerabilities, developer setup regressions, and feature-gate leaks. Review without changing files.

For a generic thermo-nuclear or deep review without a narrower focus, use `skill://thermos`. For maintainability alone, use `skill://thermo-nuclear-code-quality-review`.

## Scope

Report issues introduced or worsened by added or modified code. Read unchanged callers and dependencies to establish consequences, but keep unrelated existing vulnerabilities out of the findings.

## Audit

- Trace changed behavior through callers, shared state, persistence, and cross-package boundaries.
- Check trust boundaries, authorization, sensitive data handling, and error paths.
- Check existing developer workflows for renamed secrets or environment variables, changed ports, new required scripts, and manual setup requirements. An optional workflow or ordinary package installation is not itself a regression.
- Trace feature flags and internal-only checks through every affected entry point.
- Respect intentional, bounded removals and breaking changes. Report unintended consequences, underestimated risk, or evidence of malicious behavior rather than relabeling the requested behavior as a bug.

## Evidence

Finish reachable research before presenting a finding. If backend code or caller validation can settle a concern, inspect it rather than reporting a conditional accusation.

Each finding must include:

- `file:line` in the changed code.
- The reachable trigger and affected behavior or invariant.
- Evidence from the traced path or a reproduction.
- Priority and confidence proportional to the demonstrated impact.
- A concrete remedy that preserves the intended change.

State inaccessible dependencies and unresolved assumptions as unchecked areas, not established bugs. A clean review is not a guarantee that no bugs remain.

## PR discussion

Complete the independent audit before reading review comments. If medium- or high-risk findings exist and the change has a PR or MR, inspect its discussion with `gh` or `glab`.

Evaluate others' findings against the code. Incorporate valid evidence, deduplicate matching findings, and attribute findings sourced from another reviewer or bot.

## Output

Return prioritized findings first, followed by a brief verdict and unchecked areas. Keep severity tied to user impact. State when no material issues were found.
