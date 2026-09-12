# NOSTROMO — design language

**MK.II · September 2026 · accepted terminal baseline**

NOSTROMO is a readable spacecraft command console: near-black surfaces, warm
amber controls, cool cyan navigation, square instrument frames, and sparse status
labels. The user requested a retro-futuristic HUD from a 1980s science-fiction film
and approved this direction for reuse beyond the terminal.

## Inspiration

The creative reference is the late-1970s/1980s science-fiction control room:
phosphor displays, physical instrument panels, engineering consoles, utilitarian
ship signage, and vector-like schematics. The name also connects to this Mac's
existing hostname, `Nostromo`, and evokes the spacecraft in *Alien* (1979), an
adjacent-era visual reference. This is our interpretation, not a reproduction of a
film prop, an official theme, or a sampled film palette.

Keep the feeling practical and inhabited: a console somebody works at for hours.
Use compact labels such as COMMAND DECK, SYS, NAV, and VCS for orientation.
Keep ordinary tasks and help text understandable. A decorative spacecraft is fine;
a fabricated security scan, connection check, or “systems nominal” reading is not.

## Colour tokens

[tokens.json](tokens.json) is the portable palette reference; [tokens.css](tokens.css)
exports the same values as `--nostromo-*` properties. Existing application configs
contain explicit copies, so edits are not automatically propagated. Update these
exports and each affected application together when revising the palette.

| `background` | `#0b1012` |
| `surface` | `#131d21` |
| `surfaceActive` | `#1b2b30` |
| `selection` | `#30494c` |
| `rail` | `#263d43` |
| `border` | `#526970` |
| `muted` | `#71858a` |
| `foreground` | `#ddd3b8` |
| `foregroundBright` | `#f5edda` |
| `amber` | `#e9ae55` |
| `amberBright` | `#ffd58a` |
| `cyan` | `#78c7c4` |
| `cyanBright` | `#a2e5df` |
| `success` | `#9fbc85` |
| `danger` | `#f07167` |
| `dangerBright` | `#ff9385` |
| `blue` | `#719fae` |
| `violet` | `#b69ac7` |

### Assign colours by role

- Background and surface: the overall canvas and quiet panels.
- Foreground: normal text, code, and long output. Bright foreground: selected text.
- Amber: machine identity, primary control, active border, Git branch, command pointer.
- Cyan: paths, navigation, links, timestamps, secondary indicators, cached memory.
- Success: positive states and lower usage. Danger: failures, conflicts, high usage.
- Muted: supporting labels and timestamps/durations. Border and rail: separators,
  not small body text. SurfaceActive: focused rows; selection: selected text/commits.
- Blue and violet: supporting ANSI/syntax categories; keep them visually secondary.

Use labels or symbols alongside semantic colour. Amber is also the conventional
ANSI yellow, so applications may use it for warnings. It never means “safe” by
itself. Do not recolour all terminal output amber: preserve errors and syntax cues.

## ANSI mapping

The 16 terminal colours are in the `ansi` object in tokens.json and the
`--nostromo-ansi-0` through `--nostromo-ansi-15` CSS properties. Preserve conventional
red/error, green/success, yellow/warning and cyan/information relationships when
porting. Programs that emit ANSI colours inherit the palette; programs with their
own RGB themes need explicit configuration.

## Typography and geometry

The terminal uses **JetBrainsMono Nerd Font Mono**, 14 pt, with a 10% cell-height
increase. Use the installed fixed-width family, not a similarly named proportional
variant. For the web, use the provided monospace fallback stack if that font is not
available; the tokens do not ship or download a font.

Use 20 px horizontal / 14 px vertical terminal padding, opaque surfaces, thin square
frames, and modest spacing. For other products, treat these as proportions rather
than universal measurements: web pixels and terminal points are not equivalent.
Keep labels short, lightly letter-spaced, and uppercase; retain normal case for
paths, commands, user content, and prose. Avoid long uppercase paragraphs.

The startup panel is 60 columns including its left margin and switches to a short
label below 64 columns. Its contents occupy seven framed lines plus spacing.
The daily prompt remains two lines. The long rule fills available width; crowded
paths or Git state may still wrap in very narrow panes.

## Motion and rendering

Current implementation: opaque near-black background, blinking amber block cursor,
no shader, no blur, no ambient animation, and no permanent monitoring process.
`hud` is a snapshot. `top` starts an explicitly requested live monitor and exits
with `q`. Prompt time is local time when drawn, not a continuously ticking clock.
If motion is introduced later, keep it subtle, optional, and compatible with
reduced-motion preferences. Text legibility takes precedence over CRT effects.

## Reuse in other places

For a browser start page, editor, dashboard, launcher, or voice-control surface:

1. Start with background, foreground, amber, and cyan; add secondary colours only
   when a real state or syntax category needs them.
2. Use one compact title/status strip and clear content regions. Avoid filling
   unused space with invented readings or decorative warnings.
3. Make the active personal/company/freelance identity textual and explicit when
   we implement those contexts. The current terminal does not implement them.
4. Keep focus visible and pair state colours with labels. Check actual contrast
   at the chosen size/background before using the palette in a new interface.
5. Keep semantics constant across products: cyan navigation stays cyan navigation.

Minimal web adoption:

```css
@import url("./tokens.css");

.command-deck {
  color: var(--nostromo-foreground);
  background: var(--nostromo-background);
  font-family: var(--nostromo-font-mono);
  border: 1px solid var(--nostromo-border);
}
.command-deck a { color: var(--nostromo-cyan); }
.command-deck :focus-visible { outline: 2px solid var(--nostromo-amber); }
```

## Implementations and references

The current implementations are mapped in [SETUP.md](SETUP.md). The appearance
uses supported [Ghostty configuration](https://ghostty.org/docs/config/reference),
[Starship formatting](https://starship.rs/config/), and
[Fastfetch custom logos](https://github.com/fastfetch-cli/fastfetch/wiki/Logo-options).
The spacecraft diagram and layout are local customizations; these references
explain implementation capabilities rather than supply a borrowed theme.
