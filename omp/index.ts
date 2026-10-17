// Adds pstack's routing instruction to main sessions so qualifying work enters
// poteto-mode without the user typing /skill:poteto-mode. Subagents skip it:
// their brief already says what to do. PSTACK_ROUTING=off disables it.
import { readFileSync } from "node:fs";
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

const routing = readFileSync(new URL("./routing.md", import.meta.url), "utf8");

export default function pstack(pi: ExtensionAPI): void {
  pi.on("before_agent_start", (event, ctx) => {
    if (ctx.agent?.kind === "sub" || process.env.PSTACK_ROUTING === "off") return;
    return { systemPrompt: [...event.systemPrompt, routing] };
  });
}
