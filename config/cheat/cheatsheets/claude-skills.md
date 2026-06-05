Claude Code skill lifecycle (this machine has three flavors).

# flavors

    marketplace-plugin skills   shipped inside an installed plugin (see claude-plugins)
    cavekit / npx-skills        npx skills add <repo> -> ~/.agents/skills -> symlinked into ~/.claude/skills/
    repo-managed personal       authored here in dotfiles, symlinked by dotfiles-configure

Any dir at ~/.claude/skills/<name>/SKILL.md auto-loads next session as <name>@skills-dir.

# repo-managed skills (the dotfiles way)

source of truth:   config/claude/skills/<name>/SKILL.md
symlinked to:       ~/.claude/skills/<name>   (entry in bin/dotfiles-configure EXPLICIT_GENERAL)
loads as:           <name>@skills-dir

shipped: link-check  -> validate links are live + contain cited content + support the claim
                        run: /link-check <file|dir|--diff>

# add a skill

    mkdir -p config/claude/skills/<name>
    $EDITOR config/claude/skills/<name>/SKILL.md      # frontmatter: name + description
    # add a Symlink(REPO_CONFIG/"claude/skills/<name>", HOME/".claude/skills/<name>") to dotfiles-configure
    dotfiles-configure --dry                          # preview
    dotfiles-configure                                # apply
    # restart Claude session to load

SKILL.md frontmatter (minimum):

    ---
    name: <name>
    description: > what it does + trigger phrases so Claude knows when to fire it
    ---

# update / remove

    update:  edit config/claude/skills/<name>/SKILL.md  (symlink = live, just restart session)
    remove:  delete the Symlink entry in dotfiles-configure, then
             dotfiles-configure --clean-broken

# native helpers

    claude plugin init <name>        # scaffold at ~/.claude/skills/<name>/ (not repo-tracked)
    claude plugin details <name>     # components + token cost

note: the ~/.claude/skills/ dir must exist before symlinking (Claude/cavekit create it;
else `mkdir -p ~/.claude/skills`).

see also: claude-plugins, cavekit, claude
