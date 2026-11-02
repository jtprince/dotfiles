# Codex parity

§G

Dotfile-managed Codex setup mirrors compatible Claude directives, safety, tools, hooks, skill, notifications.

§C

- macOS + Linux; commands resolve via `PATH`.
- `sandbox_mode = "workspace-write"`; `approval_policy = "on-request"`.
- model selection unpinned.
- Claude marketplaces/plugins/cache shims ⊥ scope.
- Codex credentials/history/DB/cache/plugin state ⊥ managed.
- commit/push/PR ⊥ without explicit approval.
- missing `SessionEnd`/`Notification` ⊥ approximated via `Stop`.
- direct `ruff` ? absent; lint via repository `pre-commit` environment.

§I

file: `~/.codex/AGENTS.md` → global Git directives
file: `~/.codex/config.toml` → permissions, TUI, notifications, MCP
file: `~/.codex/hooks.json` → Serena lifecycle hooks
file: `~/.codex/rules/default.rules` → Git/`gh` approval policy
skill: `link-check` → shared Claude + Codex workflow
cmd: `dotfiles-configure --dry` → preview links + filters, no writes
cmd: `dotfiles-configure` → idempotent links + filters
cmd: `codex execpolicy check --rules <file> -- <cmd>` → decision JSON

§V

V1: global Codex guidance contains commit/push/publish gate + explicit-path staging; repo `AGENTS.md` remains layered
V2: workspace edits auto-run; sandbox escape + sensitive commands → approval
V3: `git commit`, `git push`, `gh pr create`, `gh pr merge`, `gh release create`, blanket `git add` → prompt
V4: `git add <path>`, `git add -u`, `git add -p` ≠ blanket rule match
V5: Git blob excludes root `model`, `[projects.*]`, `[tui.model_availability_nux]`; live file retains them
V6: MCP set = `serena`, `headroom`, `tokensave`; Serena args include `--context=codex --project-from-cwd`
V7: hooks use Codex-supported overlap only: `SessionStart`, `PreToolUse`, `UserPromptSubmit`, `PostToolUse`, `Stop`
V8: RTK cleanup, context-mode repair, Claude `SessionEnd`/`Notification` hooks ∉ Codex config
V9: `link-check` single client-neutral source → Claude + Codex skill links
V10: `dotfiles-configure` dry run changes ⊥ filesystem/Git config; apply idempotent
V11: existing live Codex config/rules backed up before first replacement
V12: auth/history/DB/cache/plugin paths unchanged
V13: completion + approval notifications reach Kitty without duplicate hook wiring
V14: execpolicy tests pass ∀ command token as separate argv
V15: changed Python files pass Ruff format check without rewrite
V16: baseline-wide check failures ∉ changed-file verification result; unrelated rewrites reverted

§T

id|status|task|cites
T1|x|add tracked Codex guidance/config/hooks/rules + TOML clean filter|V1,V2,V3,V4,V5,V6,V7,V8,V13,I.file
T2|x|promote `link-check`; wire Codex/shared symlinks + filter registration|V9,V10,V11,V12,I.skill,I.cmd
T3|x|parse, policy-test, filter-test, dry-run, activate links, verify fresh Codex session|V1,V2,V3,V4,V5,V6,V7,V8,V9,V10,V11,V12,V13,V14,I.cmd

§B

id|date|cause|fix
B1|2026-07-16|zsh scalar loop passed full command as one argv|V14
B2|2026-07-16|`ruff` absent from `PATH`|use `pre-commit`
B3|2026-07-16|pre-commit bootstrap blocked by sandbox DNS|rerun with network approval
B4|2026-07-16|changed Python file not Ruff-formatted|V15
B5|2026-07-16|sandbox denied symlink creation under `~/.codex`|rerun installer with scoped approval
B6|2026-07-16|sandbox denied nested Codex app-server init|rerun ephemeral check with scoped approval
B7|2026-07-16|`codex doctor` found pre-existing damaged runtime DB|V12; report, ⊥ mutate generated state
B8|2026-07-16|repo-wide pre-commit baseline failed + rewrote unrelated files|V16
