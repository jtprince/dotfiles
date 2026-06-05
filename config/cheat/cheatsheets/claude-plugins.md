Managing Claude Code plugins & marketplaces (CLI-first).

# marketplaces

    claude plugin marketplace add <github-repo|url|path>   # e.g. JuliusBrussee/caveman
    claude plugin marketplace list
    claude plugin marketplace update [name]                # all if no name
    claude plugin marketplace remove <name>                # alias: rm

# plugins

    claude plugin install <plugin@marketplace>             # alias: i
    claude plugin list
    claude plugin enable <plugin>
    claude plugin disable [plugin]
    claude plugin update <plugin>                          # restart to apply
    claude plugin uninstall <plugin>                       # alias: remove
    claude plugin details <name>                           # components + token cost
    claude plugin prune                                    # drop unused auto-deps
    claude plugin validate <path>                          # check a manifest
    claude plugin init <name>                              # scaffold skill at ~/.claude/skills/<name>/
    claude plugin tag [path]                               # {name}--v{version} release tag

# where state lives

    ~/.claude/plugins/known_marketplaces.json
    ~/.claude/plugins/installed_plugins.json
    ~/.claude/plugins/marketplaces/<marketplace>/...       # cached repos

# this repo's convention

Plugins/marketplaces are pinned declaratively in config/claude/settings.json
(symlinked to ~/.claude/settings.json), so they survive a fresh machine:

    "enabledPlugins":        { "caveman@caveman": true, ... }
    "extraKnownMarketplaces":{ "caveman": { "source": {...} }, ... }

The CLI still fetches/caches the actual plugin once per machine — settings.json
declares intent, `claude plugin install` populates the cache.

see also: claude-skills, claude, caveman, cavekit
