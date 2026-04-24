# Vim/Neovim Built-in Text Objects — Cheatsheet

Use **operators** (`d`, `c`, `y`, `gU`, `gu`, `v`, `!`, etc.) with **text objects**:

- `i{obj}` = **inner** (contents only)
- `a{obj}` = **around** (includes delimiters / surrounding space)

Examples:  
`diw` → delete inner word  
`va"` → visually select around double quotes  
`ci(` → change inside parentheses

---

## Words & WORDs
| Object       | Meaning                 | Notes                                       |
|--------------|-------------------------|---------------------------------------------|
| `iw` / `aw`  | inner / around word     | `aw` usually includes trailing space        |
| `iW` / `aW`  | inner / around WORD     | WORD = non-blank run (includes punctuation) |

---

## Sentences & Paragraphs
| Object       | Meaning                 |
|--------------|-------------------------|
| `is` / `as`  | inner / around sentence |
| `ip` / `ap`  | inner / around paragraph|

---

## Quotes
| Object       | Meaning                      |
|--------------|------------------------------|
| `i"` / `a"`  | inner / around double quotes |
| `i'` / `a'`  | inner / around single quotes |
| `i\`` / `a\``| inner / around backticks     |

---

## Balanced Pairs
| Object                               | Pair    | Aliases / Notes                              |
|--------------------------------------|---------|----------------------------------------------|
| `i(` / `a(`, `i)` / `a)`             | ( … )   | `ib` / `ab` historically alias “block/paren” |
| `i[` / `a[`, `i]` / `a]`             | [ … ]   | —                                            |
| `i{` / `a{`, `i}` / `a}`             | { … }   | Often used for “code block”                  |
| `i<` / `a<`                          | < … >   | For angle brackets                           |

---

## HTML/XML Tags *(requires `matchit` or `vim-matchup`)*
| Object       | Meaning                 |
|--------------|-------------------------|
| `it` / `at`  | inner / around tag set  |

---

## Common Combos
| Command | Action                           |
|----------|----------------------------------|
| `ciw`    | change inner word                |
| `diw`    | delete inner word                |
| `yaw`    | yank around word                 |
| `viw`    | visually select inner word       |
| `ci"`    | change inside double quotes      |
| `da"`    | delete around double quotes      |
| `di'`    | delete inside single quotes      |
| `ci(`    | change inside parentheses        |
| `da[`    | delete around brackets           |
| `vip`    | visually select inner paragraph  |
| `dap`    | delete around paragraph          |

---

## Notes & Tips
- **Inner vs Around**  
  - `i` = content only  
  - `a` = content + delimiters / spacing  

- **Counts work**  
  - `2da"` deletes two quoted regions in sequence (especially with `targets.vim`).  

- **Pair matching**  
  - Use `%` to jump between matching pairs before an operator.  

- **Tags**  
  - `it` / `at` require a tag-aware matcher (`andymass/vim-matchup` or legacy `matchit`).  
