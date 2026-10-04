#!/usr/bin/env bash
# Usage: apply-seats.sh <seat>=<selector[:level]|unset> ...
# Seats: pstack-code pstack-judge pstack-panel-a pstack-panel-b pstack-panel-c
# Merges into the global omp config without touching non-pstack keys.
set -euo pipefail

command -v jq >/dev/null || { echo "apply-seats: jq is required" >&2; exit 2; }
[ $# -gt 0 ] || { sed -n '2,4p' "$0" >&2; exit 2; }

agents_for() {
	case "$1" in
	pstack-code) echo "poteto-agent pstack-code" ;;
	pstack-judge) echo "poteto-agent-deep pstack-judge" ;;
	pstack-panel-a | pstack-panel-b | pstack-panel-c) echo "$1" ;;
	*) return 1 ;;
	esac
}

roles=$(omp config get modelRoles --json | jq -c '.value // {}')
overrides=$(omp config get task.agentModelOverrides --json | jq -c '.value // {}')

for pair in "$@"; do
	seat=${pair%%=*}
	value=${pair#*=}
	[ "$seat" != "$pair" ] && [ -n "$value" ] || { echo "apply-seats: expected <seat>=<value>, got '$pair'" >&2; exit 2; }
	agents=$(agents_for "$seat") || { echo "apply-seats: unknown seat '$seat'" >&2; exit 2; }
	alias="@$seat"
	if [ "$value" = unset ]; then
		roles=$(jq -c --arg k "$seat" 'del(.[$k])' <<<"$roles")
		for agent in $agents; do
			overrides=$(jq -c --arg a "$agent" --arg v "$alias" 'if .[$a] == $v then del(.[$a]) else . end' <<<"$overrides")
		done
	else
		roles=$(jq -c --arg k "$seat" --arg v "$value" '.[$k] = $v' <<<"$roles")
		for agent in $agents; do
			overrides=$(jq -c --arg a "$agent" --arg v "$alias" '.[$a] = $v' <<<"$overrides")
		done
	fi
done

omp config set modelRoles "$roles"
omp config set task.agentModelOverrides "$overrides"
