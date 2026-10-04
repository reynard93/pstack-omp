# Set up pstack

In this page you install the plugin, pick which models pstack uses, and run your first task. Setup is a few commands plus a short conversation.

## Install the plugin

In an omp session, add the marketplace and install the plugin:

```text
/marketplace add <owner>/pstack-omp
/marketplace install pstack@pstack-omp
```

A local checkout works as a marketplace too, for example `/marketplace add ~/Code/pstack-omp`. Then run `/reload-plugins`, or restart omp, so the skills and agents load.

From a shell, the same steps are:

```sh
omp plugin marketplace add <owner>/pstack-omp
omp plugin install pstack@pstack-omp
```

## Pick your models

Run:

```text
/skill:setup-pstack
```

[`/skill:setup-pstack`](../../skills/setup-pstack/SKILL.md) asks for a reasoning budget, detects the models you have access to with `omp models`, shows you each seat (code, judge, and the three panel seats), and asks what you want. Answer the questions. It writes the seat models to `~/.omp/agent/config.yml`. Each seat becomes a model role (`modelRoles.pstack-code`, `pstack-judge`, `pstack-panel-a`, `pstack-panel-b`, `pstack-panel-c`), and `task.agentModelOverrides` points each pstack agent at its seat.

pstack's subagents are omp agents, and each one sits on a seat:

- The code seat runs `poteto-agent`, the poteto-style delegate that builds features, fixes bugs, refactors, and chases perf and hillclimb targets. It also runs `pstack-code`, the plain worker behind `/skill:how` explorers, `/skill:why` investigators, and `/skill:swarm` workers.
- The judge seat runs `poteto-agent-deep`, the poteto-style delegate for the hardest changes. It also runs `pstack-judge`, which handles judgment and prose, such as the `/skill:how` explainer, the `/skill:why` synthesizer, and the `/skill:reflect` reviewers.
- The three panel seats run `pstack-panel-a`, `pstack-panel-b`, and `pstack-panel-c`. Each one takes a seat on the `/skill:arena` and `/skill:architect` runner panels, the `/skill:interrogate` reviewer panel, and the arena cross-judge pool. By default panel A is an Anthropic model, panel B an OpenAI model, and panel C an xAI or Google model, so a panel has three model families.
- `comment-sicko`, the reviewer behind `/skill:no-comments`, always runs on your session model.

You only set what you care about. You might be wondering what happens if you'd rather not pick at all. Leave a seat unset and its agents follow your session model. With no setup, every pstack agent runs on whatever model you chat with. A rerun of `/skill:setup-pstack` starts from the seats you already have. You can also change a seat later in `/model` (the Roles view), or a single agent in the `/agents` hub.

## Accept the verification offer, or don't

At the end of setup, `/skill:setup-pstack` looks for a way to prove app behavior in your project, either a `verify-*` skill or an existing harness. If it finds neither, it offers once to generate one with [`/skill:create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.omp/skills/verify-<app>/`, a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. You can run `/skill:create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers when it earns its place.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
/skill:poteto-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

Watch the todo list. Its first items are the matched playbook's steps copied in, the Feature playbook for this prompt. If `/skill:poteto-mode` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. `/skill:poteto-mode` is sticky. It stays on for the conversation until you opt out by saying so.

Next: [Route work through `/skill:poteto-mode`](./02-poteto-mode.md).
