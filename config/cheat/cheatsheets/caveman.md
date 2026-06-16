https://github.com/JuliusBrussee/caveman

claude plugin marketplace add JuliusBrussee/caveman 
claude plugin install caveman@caveman

/caveman
/caveman lite
/caveman full
/caveman ultra

can also: "start caveman" or "stop caveman"



## cavemem broke: "NODE_MODULE_VERSION" / "Could not locate the bindings file"

**Symptom:** stop-hook error like
`...better_sqlite3.node was compiled against ... NODE_MODULE_VERSION 127. This version of Node.js requires NODE_MODULE_VERSION 147.`

**Cause:** `brew upgrade` relinked the unversioned `node` formula (newer Node) as default. cavemem's prebuilt `better-sqlite3` only matches **Node 22 (ABI 127)**. Not a project bug — no amount of project-level `npm rebuild` fixes it.

**Diagnose (read-only):**
```bash
node -v                              # which node is active
node -p process.versions.modules     # its ABI; cavemem needs 127 (= Node 22)
brew list --formula | grep -E '^node(@|$)'   # what's installed
```

**Fix (Node 22 already installed)**:
```
brew unlink node && brew link --overwrite --force node@22   # default -> v22 LTS
cd /opt/homebrew/lib/node_modules/cavemem && npm rebuild better-sqlite3
hash -r && cavemem hook run stop --ide claude-code          # expect {"ok":true}
```

**Prevent recurrence: 

`brew pin node@22`

Gotchas:
- npm rebuild must run in the global `/opt/homebrew/lib/node_modules/cavemem` dir — NOT your project or ~
- Do NOT use --build-from-source on a too-new Node — it deletes the working binary, then fails to compile (better-sqlite3 11.x won't build on Node 26+). Plain npm rebuild just fetches the matching prebuild.
- ABI map: 127 = Node 22, 137 = Node 24, 147 = Node 26. cavemem wants 127.
