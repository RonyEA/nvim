# Debugging Workflow (Neovim + nvim-dap)

This guide is a complete, practical flow for debugging in this config.

## Keymaps You Have

Core DAP controls (LazyVim defaults):

- `<leader>db`: Toggle breakpoint
- `<leader>dB`: Set conditional breakpoint
- `<leader>dc`: Run / continue
- `<leader>da`: Run with args
- `<leader>dC`: Run to cursor
- `<leader>di`: Step into
- `<leader>dO`: Step over
- `<leader>do`: Step out
- `<leader>dP`: Pause
- `<leader>dr`: Toggle DAP REPL
- `<leader>du`: Toggle DAP UI
- `<leader>de`: Evaluate expression under cursor / selection
- `<leader>dw`: Hover widget inspect
- `<leader>dl`: Run last
- `<leader>dt`: Terminate

Language-specific:

- Python:
  - `<leader>dpm`: Debug test method
  - `<leader>dpc`: Debug test class
  - Visual `<leader>dps`: Debug selection
- R:
  - `<leader>dR`: Debug current file

Custom recipe:

- `<leader>dQ`: Apply custom breakpoint recipe from `lua/debug/bp_trading.lua`

## Step-by-Step Debug Process

1. Open the file you want to debug.
2. Put the cursor on the line where execution should stop.
3. Add a breakpoint with `<leader>db`.
4. Optional: add a conditional breakpoint with `<leader>dB`.
5. Start debugging:
   - Generic: `<leader>dc`
   - Python tests: `<leader>dpm` or `<leader>dpc`
   - Python selection (visual mode): `<leader>dps`
   - R file: `<leader>dR`
6. When paused, inspect values:
   - Inline virtual text appears at end-of-line.
   - Hover inspect with `<leader>dw`.
   - Evaluate expression with `<leader>de`.
7. Step through code:
   - Into: `<leader>di`
   - Over: `<leader>dO`
   - Out: `<leader>do`
   - Continue: `<leader>dc`
8. Use debug REPL for live experiments:
   - Open with `<leader>dr`
   - Type expressions and press Enter.
9. Use DAP UI panels for broader state:
   - Toggle UI with `<leader>du`
   - Check `scopes`, `breakpoints`, `stacks`, `watches`, `repl`, `console`
10. Work with watches in the DAP UI:
   - In `watches`, press `e` to add/edit expression
   - Press `d` to remove expression
   - Press `<CR>` to expand values
11. End or rerun:
   - Terminate: `<leader>dt`
   - Re-run previous config: `<leader>dl`

## Debug Console and Expression Testing

Use two approaches:

- Quick eval in code context: `<leader>de`
  - Normal mode evaluates near cursor.
  - Visual mode evaluates selected expression.
- Interactive debug REPL: `<leader>dr`
  - Best for trying multiple expressions quickly.
  - Examples:
    - Python: `len(items)`, `obj.attr`, `my_fn(x)`
    - R: `length(df$col)`, `str(model)`, `summary(x)`

## Watches, Scopes, and Frames

- `scopes`: local/global variables for current frame.
- `stacks`: call stack; move frames to inspect older contexts.
- `watches`: expressions you want to track while stepping.
- `breakpoints`: all active breakpoints.

Tip: frame navigation is available through DAP mappings:

- `<leader>dj`: down frame
- `<leader>dk`: up frame

## Troubleshooting

- Breakpoint not hit:
  - Confirm debugger started from correct entrypoint.
  - Confirm source path and interpreter/environment are correct.
- Python env mismatch:
  - This config prefers `VIRTUAL_ENV`, then local `.venv/venv/env`, then `python3`.
- R debug not starting:
  - Ensure `R` exists in PATH.
  - In R, install: `install.packages("vscDebugger")`.
- UI not visible:
  - Toggle with `<leader>du`.

## Collision Cleanup Notes

To preserve LazyVim defaults, custom mappings were moved so defaults stay available:

- Kept default `<leader>dB` for conditional breakpoint.
- Kept default `<leader>dr` for DAP REPL.
- R file-debug uses `<leader>dR`.
- Breakpoint recipe uses `<leader>dQ`.
