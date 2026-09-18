-- Minified JSON -- the whole document on one line -- reflowed with jq.
--
-- Nothing else in the JSON setup helps with that shape. Treesitter would still
-- highlight it and rainbow-delimiters would still colour the brackets, but
-- with `wrap` on globally (lua/config/options.lua) a one-line document renders
-- as a solid block of text; folding has nothing to fold, because every node
-- opens and closes on line 1; and treesitter-context has no parent line to
-- pin. jsonfly can still jump around it -- you still cannot read it.
--
-- `jq .` is the fix. It reindents to two spaces and preserves key order (it
-- only sorts under -S), and since jq 1.7 it round-trips number literals rather
-- than pushing them through a double.
--
-- This only ever touches the BUFFER. The file on disk is unchanged until you
-- `:w`, and `u` puts the original single line back. The buffer is deliberately
-- left 'modified' afterwards rather than faked back to clean: that is the
-- truth -- it no longer matches disk -- and it means a stray `:q` stops to ask
-- rather than silently deciding for you either way.
--
-- Entry points:
--   :JsonFormat / <leader>cJ   reflow the current buffer, any time
--   automatic                  on opening a file that is already minified;
--                              set `vim.g.json_auto_reflow = false` in
--                              lua/config/options.lua to turn that off

local M = {}

-- Automatic path only; :JsonFormat ignores this.
--
-- 1.5MB is not arbitrary -- it is snacks.nvim's own bigfile size threshold
-- (snacks/bigfile.lua). Above it snacks has stripped treesitter, LSP and
-- folding off the buffer for a reason, so reflowing would buy indentation
-- alone while costing a multi-second jq round trip on every open. Below it,
-- the reclaim path further down takes the buffer back off snacks and hands it
-- the full JSON treatment.
local MAX_AUTO_BYTES = 1.5 * 1024 * 1024

-- What "minified" means here: one or two lines, at least one of them very
-- long. The line-count test keeps this off ordinary formatted JSON; the length
-- test keeps it off a short one-liner like {"ok":true}, which needs no help.
local MAX_MINIFIED_LINES = 2
local MINIFIED_LINE_BYTES = 256

local JSON_FILETYPES = { json = true, jsonc = true, json5 = true }

local function looks_minified(buf)
  if vim.api.nvim_buf_line_count(buf) > MAX_MINIFIED_LINES then
    return false
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, MAX_MINIFIED_LINES, false)) do
    if #line > MINIFIED_LINE_BYTES then
      return true
    end
  end
  return false
end

local function is_stream(buf)
  -- lua/config/autocmds.lua maps .jsonl / .ndjson onto the `json` filetype.
  -- Those hold one JSON value PER LINE, so a long line is the format working
  -- as designed, not minification -- and a one-record file would otherwise
  -- trip the test above. jq would reflow the whole stream into pretty-printed
  -- objects and break the one-record-per-line contract on the next `:w`, so
  -- they are excluded from the automatic path.
  local name = vim.api.nvim_buf_get_name(buf)
  return name:match("%.jsonl$") ~= nil or name:match("%.ndjson$") ~= nil
end

--- Pipe a buffer through `jq .`. Returns true if the buffer was rewritten.
---
--- `quiet` suppresses the parse-error notification, and is passed on the
--- automatic path: nothing was asked for and nothing was changed, so there is
--- nothing to report. A minified .jsonc that still carries comments would
--- otherwise warn on every single open. :JsonFormat and <leader>cJ were asked
--- for, so they still explain themselves.
function M.format(buf, quiet)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf

  if vim.fn.executable("jq") == 0 then
    vim.notify("JSON: jq is not installed", vim.log.levels.WARN)
    return false
  end
  if not vim.bo[buf].modifiable then
    vim.notify("JSON: buffer is not modifiable", vim.log.levels.WARN)
    return false
  end

  -- A list as the first argument is argv, not a shell string, so nothing here
  -- is word-split or glob-expanded; a list as the second is stdin.
  local input = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local output = vim.fn.systemlist({ "jq", "." }, input)
  if vim.v.shell_error ~= 0 then
    -- Comments in a .jsonc / .json5 file land here -- jq only speaks strict
    -- JSON -- and so does genuinely malformed input, which is worth seeing.
    if not quiet then
      vim.notify("JSON: jq could not parse this buffer\n" .. table.concat(output, "\n"), vim.log.levels.WARN)
    end
    return false
  end

  -- winsaveview reads the CURRENT window, so it is only meaningful when this
  -- is the buffer on screen.
  local focused = buf == vim.api.nvim_get_current_buf()
  local view = focused and vim.fn.winsaveview() or nil

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  -- The saved column is routinely past the end of the new line 1 -- that is
  -- the entire point of the exercise -- so this is allowed to fail rather than
  -- throw an error out of a file-open handler.
  if view then
    pcall(vim.fn.winrestview, view)
  end
  return true
end

-- Take a buffer back from snacks.nvim's bigfile handler.
--
-- snacks flags a file as "bigfile" on EITHER of two tests: over 1.5MB, or an
-- average line length over 1000 bytes. The second one catches every minified
-- JSON document above about a kilobyte -- a 5KB config file, comfortably small
-- -- and the consequence is not cosmetic: snacks sets the FILETYPE to
-- "bigfile" and never sets it back (it restores `syntax`, not `filetype`). So
-- the buffer gets no treesitter, no jsonls, no jsonfly, no treesitter-context,
-- and the `json` autocmd below never fires either.
--
-- Once the document has been reflowed, its average line length is a few dozen
-- bytes and the verdict no longer holds, so this undoes it: the real filetype
-- goes back on, and the window options snacks changed in its `setup` callback
-- are reset to their global values -- which is what they were before snacks
-- overrode them window-locally.
local function reclaim_from_bigfile(buf, ft)
  vim.b[buf].completion = nil

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win].foldmethod = vim.go.foldmethod
    vim.wo[win].statuscolumn = vim.go.statuscolumn
    vim.wo[win].conceallevel = vim.go.conceallevel
  end

  -- snacks runs :NoMatchParen, which is global and which it never reverses.
  -- Bracket matching is worth more in JSON than almost anywhere else, so it
  -- comes back on -- and it has to be global, because that is the only form
  -- the command has.
  if vim.fn.exists(":DoMatchParen") == 2 then
    pcall(vim.cmd, "DoMatchParen")
  end

  -- Last, because this is what fires FileType and brings treesitter, jsonls
  -- and the rest in. snacks' own detection bails out early when the current
  -- filetype is already "bigfile", so this does not get overridden back.
  vim.bo[buf].filetype = ft
end

-- Shared by both entry points. `reclaim` is true only on the bigfile path.
local function auto_reflow(buf, ft, reclaim)
  if vim.g.json_auto_reflow == false then
    return
  end
  -- Real files only. A scratch buffer someone has just `:set ft=json` on is
  -- being typed into, not read, and half-typed JSON is not minified JSON --
  -- it is invalid, and jq would say so on every keystroke.
  if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
    return
  end
  if is_stream(buf) or not looks_minified(buf) then
    return
  end

  local bytes = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
  if bytes > MAX_AUTO_BYTES then
    vim.notify(
      ("JSON: minified, %.1f MB -- too big to reflow on open, run :JsonFormat"):format(bytes / 1024 / 1024),
      vim.log.levels.INFO
    )
    return
  end

  -- Deferred out of the file-read path: FileType fires partway through the
  -- read, so rewriting every line from inside it would happen before the
  -- window has settled, which is what winrestview needs. On the bigfile path
  -- it also puts this after snacks' own handler has finished degrading the
  -- buffer, so there is something coherent left to undo.
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) or not M.format(buf, true) then
      return
    end
    if reclaim then
      reclaim_from_bigfile(buf, ft)
    end
    vim.notify("JSON: minified on disk, reflowed with jq -- `u` to undo", vim.log.levels.INFO)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("JsonFormat", function()
    M.format(0)
  end, { desc = "Reflow the current buffer with jq" })

  local group = vim.api.nvim_create_augroup("ron_json", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "json", "jsonc", "json5" },
    callback = function(ev)
      vim.keymap.set("n", "<leader>cJ", function()
        M.format(ev.buf)
      end, { buffer = ev.buf, desc = "Reflow JSON (jq)" })

      auto_reflow(ev.buf, ev.match, false)
    end,
  })

  -- The path almost every real minified file takes; see reclaim_from_bigfile.
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "bigfile",
    callback = function(ev)
      -- What the filetype WOULD have been. Safe to ask even though snacks has
      -- a catch-all `.*` pattern registered, because that function returns nil
      -- as soon as the buffer is already flagged "bigfile" -- which is exactly
      -- the situation here -- so detection falls through to the extension.
      local ft = vim.filetype.match({ buf = ev.buf })
      if not ft or not JSON_FILETYPES[ft] then
        return
      end
      auto_reflow(ev.buf, ft, true)
    end,
  })
end

return M
