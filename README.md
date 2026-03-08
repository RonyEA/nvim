# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Agent Workflow (CopilotChat)

- `<leader>aa`: Open Copilot Chat.
- `<leader>aA`: Project-aware ask (forces workspace-tool usage instead of filename guessing).
- `<leader>aw`: Run `/WorkspaceAudit` prompt (glob -> grep -> file workflow).
- Visual mode: `<leader>cq` explain, `<leader>cr` review, `<leader>cf` fix.

Tips:

- Use `@copilot` in prompts when you want tool-calling (workspace search/read/edit with approval).
- Add resources explicitly when needed: `#glob:**/*`, `#grep:pattern`, `#file:path/to/file`.
- Keep instructions in `.github/copilot-instructions.md` or `AGENTS.md` per project.

## Python and R Workflows

Python (debugging):

- `<leader>dpm`: Debug Python test method under cursor.
- `<leader>dpc`: Debug Python test class under cursor.
- Visual mode `<leader>dps`: Debug selected Python code.
- Python DAP automatically prefers `VIRTUAL_ENV`, then project `.venv/venv/env`, then `python3`.

R (debugging):

- `<leader>dR`: Start R debug for current file via nvim-dap.
- Requires R package: `install.packages("vscDebugger")`.

Debug quick reference:

- See `debug.md` for a complete end-to-end debugger workflow (breakpoints, stepping, REPL/eval, watches, scopes, and console).

REPL (daily loop):

- `vim-slime` (primary):
	- `<leader>sl`: Send line
	- Visual mode `<leader>ss`: Send selection
	- `<leader>sp`: Send paragraph
	- `<leader>sc`: Configure target pane
- `iron.nvim` (secondary REPL):
	- `<leader>rs`: Start/toggle Iron REPL
	- `<leader>rf`: Focus REPL
	- `<leader>rh`: Hide REPL
	- `<leader>il`: Send line
	- Visual mode `<leader>ic`: Send selection
	- `<leader>if`: Send file

Notes:

- `vim-slime` is enabled as the primary send workflow.
- DAP virtual text is enabled, so variable values show inline while stepping.

## Themes

Recommended themes (installed):

- `kanagawa-wave` (default): balanced contrast, low eye strain.
- `rose-pine`: soft palette with clear diagnostics.
- `nightfox` (`nordfox`, `carbonfox`): crisp code contrast.
- `gruvbox`: classic warm contrast for long sessions.
- `everforest`: muted green tone for readability.
- `vscode`: familiar visual feel from VS Code.

Theme UI picker:

- `<leader>uT`: open Telescope colorscheme picker with live preview.

## Quarto and Notebooks

`.qmd` (R/Python chunks):

- `.qmd` files are mapped to `quarto` filetype.
- `<leader>qp`: Quarto preview.
- `<leader>qr`: Quarto render.
- `<leader>qa`: Quarto activate (LSP/chunk features).

Recommended Quarto workflow (R-first):

- Start in a `.qmd` file and run `<leader>qa` once.
- Insert R chunks quickly with `<leader>qir`.
- Execute chunk code with your REPL flow (`vim-slime` or Molten).
- Keep the live document open with `<leader>qp` while editing.
- Render final output with `<leader>qr`.

Handy chunk shortcuts (`quarto`/`rmd` buffers):

- `<leader>qir`: insert
	```
	```{r}

	```
- `<leader>qip`: insert Python chunk
- `<leader>qib`: insert Bash chunk
- Visual `<leader>qwr`: wrap selection in an R chunk
- Visual `<leader>qwp`: wrap selection in a Python chunk
- Visual `<leader>qwb`: wrap selection in a Bash chunk

`.ipynb` (Python notebooks):

- Notebook files open through `jupytext` in `py:percent` style for editing in Neovim.
- Use Molten to execute cells/chunks:
	- `<leader>mj`: init kernel
	- `<leader>ml`: eval line
	- visual `<leader>mv`: eval selection
	- `<leader>mo`: open output
	- `<leader>mx`: interrupt kernel

System tools needed:

- `quarto` CLI for preview/render.
- `jupytext` (`pip install jupytext`) for `.ipynb` conversion.
- Jupyter kernel tools for Molten (for Python: `pip install pynvim jupyter ipykernel`).

## Testing and R IDE Boost

Python tests (`neotest` + pytest):

- `<leader>tn`: run nearest test
- `<leader>tf`: run tests in current file
- `<leader>td`: debug nearest test with DAP
- `<leader>ts`: toggle test summary
- `<leader>to`: open test output

R IDE support (`R.nvim`):

- `<leader>rR`: start R session
- `<leader>rQ`: stop R session
- Keeps R completion/object tooling available for `r`, `rmd`, and `quarto` files.

## Symbol Navigation (Project-Wide)

- Put cursor on a function/symbol and use:
	- `<leader>sd`: definitions (Telescope)
	- `<leader>si`: implementations (Telescope)
	- `<leader>sr`: references in project (Telescope)
	- `<leader>ss`: symbols in current file
	- `<leader>sS`: symbols in workspace
	- `<leader>so`: outgoing calls (functions called by symbol under cursor)
	- `<leader>sI`: incoming calls (functions that call symbol under cursor)

Notes:

- `<leader>sr` uses LSP references when available.
- If LSP is not attached, `<leader>sr` falls back to project-wide Telescope grep for the word under cursor.
- Call hierarchy mappings (`<leader>so`, `<leader>sI`) require LSP server support for call hierarchy.

## Diagnostics (Relevant Errors First)

- Diagnostics are tuned to reduce noise from cross-file OOP/type-analysis churn.
- Inline virtual text shows only `ERROR` by default.
- Underlines remain for `WARN` and `ERROR` so important issues are still visible.
- Python language servers are set to `openFilesOnly` diagnostics with relaxed unknown-type rules.
- Duplicate diagnostics are avoided by using `basedpyright` as the active Python type checker.

Tips:

- Toggle diagnostics on/off with LazyVim's `<leader>ud` when needed.
- Toggle Python strict diagnostics with `<leader>uP`.
- Open diagnostics in a list (Trouble) when you want full project triage.

Strict mode (`<leader>uP`) does this:

- Changes Python diagnostics scope from `openFilesOnly` to `workspace`.
- Raises type checking from `basic` to `standard`.
- Re-enables key unknown-type diagnostics as warnings.
- Useful before PRs/releases when you want deeper project-wide validation.
