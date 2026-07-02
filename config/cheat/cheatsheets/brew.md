---
tags: [ macos, security ]
---

# Homebrew trust & supply-chain (Homebrew 6.0+).
#
# The "tap not trusted" prompt on `brew upgrade`:
#   Homebrew 6.0 sets HOMEBREW_REQUIRE_TAP_TRUST=1 by default. A THIRD-PARTY tap is
#   arbitrary Ruby run with your privileges, so brew refuses to load one until you
#   `brew trust` it. Official taps (homebrew/core, homebrew/cask, homebrew/services)
#   are always trusted.
#
# Mental model (paru -> brew):
#   Arch official repos  = homebrew/core + homebrew/cask : human-reviewed PRs, bottles
#                          built by Homebrew's OWN sandboxed CI, SHA256-pinned. Don't diff.
#   AUR (review PKGBUILD) = third-party taps : arbitrary code. Review + trust the maintainer.
#   paru per-update diff  = taps are LOCAL GIT CLONES -> `git -C "$(brew --repo user/tap)" diff`
#                           (only core/cask need HOMEBREW_NO_INSTALL_FROM_API=1 to be diffable).

# ── Review a formula/cask BEFORE trusting (do this once per tap) ─────
brew info user/repo/name          # metadata, homepage, deps
brew cat  user/repo/name          # full source; check `url` + `sha256` (avoid `sha256 :no_check`)
brew cat --cask user/repo/name    # cask source
brew deps user/repo/name          # what it pulls in

# paru-style diff of a tap's changes since you last pulled:
git -C "$(brew --repo user/repo)" log --oneline -20
git -C "$(brew --repo user/repo)" diff HEAD@{1} HEAD          # what changed on last update
git -C "$(brew --repo user/repo)" log -p -- Casks/name.rb     # full history of one item

# ── Trust management ────────────────────────────────────────────────
brew trust                                   # list what's trusted
brew trust --formula user/repo/name          # trust ONE formula (least privilege — preferred)
brew trust --cask    user/repo/name          # trust ONE cask
brew trust --command user/repo/name          # trust ONE external command
brew trust user/repo                         # trust the WHOLE tap (broader; use sparingly)
brew untrust user/repo[/name]                # revoke
brew doctor                                  # flags any untrusted taps in use

# Reduce attack surface: untap taps you don't actually install from.
brew tap                                     # list taps
brew list --full-name | grep /               # installed items that come from a tap
brew untap user/repo                          # remove an unused tap (reversible: re-`brew tap`)

# ── Env vars we set (config/zsh/dot-zshenv) ─────────────────────────
#   HOMEBREW_NO_ANALYTICS=1          no telemetry
#   HOMEBREW_NO_INSECURE_REDIRECT=1  refuse https->http (MITM)
#   HOMEBREW_REQUIRE_TAP_TRUST=1     pin the 6.0 trust default
#   HOMEBREW_VERIFY_ATTESTATIONS=1   verify homebrew/core bottle build provenance (needs `gh` authed)
#
# Attestations use the `gh` CLI. If a core install errors on verification, run once without it:
HOMEBREW_VERIFY_ATTESTATIONS= brew install <formula>
gh auth status                                # confirm gh is logged in

# Optional (NOT set — breaks legit version:latest / font casks):
#   HOMEBREW_CASK_OPTS="--require-sha"         reject casks with `sha256 :no_check`

# ── Reproducibility (documented; not adopted here) ──────────────────
brew bundle dump --describe --file ~/Brewfile   # snapshot taps+formulae+casks (captures `trusted: true`)
brew bundle check                               # what's missing vs Brewfile
brew pin <formula>                              # hold at current version on upgrade
brew list --pinned

# ── Diff core/cask too (full paru parity, opt-in, slower) ───────────
# export HOMEBREW_NO_INSTALL_FROM_API=1         # makes core/cask local git clones you can diff
