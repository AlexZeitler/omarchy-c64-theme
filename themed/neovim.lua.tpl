-- Omarchy generates this file from the current theme's colors.toml. It
-- replaces the built-in template, so it has to carry everything that one
-- carried, plus the part below.
--
-- A theme that ships a file named `neovim.surfaces` containing `flat` asks
-- for three things: floating windows on the editor field instead of on a
-- shade of their own, bounded by a frame in the theme accent; no coloured
-- fill behind a markdown heading; and a selection that swaps the two theme
-- colours instead of tinting the line. Every other theme falls through to
-- aether's own mapping and is unaffected.
--
-- Why a template and not a file in the theme: omarchy-theme-set refuses any
-- *.lua that comes out of a cloned theme repository. A template lives in the
-- user's own config and is not subject to that.

local state = vim.fn.expand("~/.local/state/omarchy/current/theme")

local function theme_flag(name)
  local handle = io.open(state .. "/" .. name, "r")
  if not handle then return nil end
  local value = handle:read("*l")
  handle:close()
  return value and value:gsub("%s+$", "")
end

local flat = theme_flag("neovim.surfaces") == "flat"

local opts = {
  colors = {
    bg = "{{ background }}",
    dark_bg = "{{ dark_background }}",
    darker_bg = "{{ darker_background }}",
    lighter_bg = "{{ lighter_background }}",

    fg = "{{ foreground }}",
    dark_fg = "{{ dark_foreground }}",
    light_fg = "{{ light_foreground }}",
    bright_fg = "{{ bright_foreground }}",
    muted = "{{ muted }}",

    red = "{{ red }}",
    yellow = "{{ yellow }}",
    orange = "{{ orange }}",
    green = "{{ green }}",
    cyan = "{{ cyan }}",
    blue = "{{ blue }}",
    magenta = "{{ magenta }}",
    brown = "{{ brown }}",

    bright_red = "{{ bright_red }}",
    bright_yellow = "{{ bright_yellow }}",
    bright_green = "{{ bright_green }}",
    bright_cyan = "{{ bright_cyan }}",
    bright_blue = "{{ bright_blue }}",
    bright_magenta = "{{ bright_magenta }}",

    accent = "{{ accent }}",
    cursor = "{{ bright_foreground }}",
    foreground = "{{ foreground }}",
    background = "{{ background }}",
    selection = "{{ selection }}",
    selection_foreground = "{{ selection_foreground }}",
    selection_background = "{{ selection_background }}",
  },
}

if flat then
  local FIELD = "{{ background }}"
  local TEXT  = "{{ foreground }}"
  local FRAME = "{{ accent }}"

  -- bg_float follows this; without it a float keeps dark_background.
  opts.styles = {
    sidebars = "normal",
    floats = "normal",
  }

  -- aether derives border_highlight from blue after merging opts.colors, so
  -- the frame colour has to be set in on_colors, not in the colour table.
  opts.on_colors = function(colors)
    colors.border_highlight = FRAME
  end

  -- bg_popup stays dark_background regardless of styles.floats, so the Noice
  -- cmdline and the completion menu need their fill named explicitly.
  opts.on_highlights = function(hl)
    local field = { bg = FIELD }
    for _, group in ipairs({
      "NormalFloat", "NormalSB", "Pmenu", "PmenuExtra", "PmenuKind",
      "NoiceCmdline", "NoiceCmdlinePopup", "NoiceConfirm", "NoicePopup",
      "NoicePopupmenu", "WhichKeyFloat", "TelescopeNormal",
      "SnacksNormal", "SnacksPickerNormal",
      "BlinkCmpMenu", "BlinkCmpDoc", "BlinkCmpSignatureHelp",
    }) do hl[group] = vim.tbl_extend("force", {}, field) end

    local frame = { fg = FRAME, bg = FIELD }
    for _, group in ipairs({
      "FloatBorder", "FloatTitle", "TelescopeBorder",
      "NoiceCmdlinePopupBorder", "NoiceCmdlinePopupBorderSearch",
      "NoiceConfirmBorder", "NoicePopupBorder",
      "SnacksPickerBorder", "BlinkCmpMenuBorder",
      "BlinkCmpDocBorder", "BlinkCmpSignatureHelpBorder",
    }) do hl[group] = vim.tbl_extend("force", {}, frame) end

    hl.NoiceCmdlineIcon = { fg = FRAME, bg = FIELD }
    hl.NoiceCmdlinePopupTitle = { fg = FRAME, bg = FIELD }

    -- render-markdown.nvim hangs its heading fills on the diff groups: H1 on
    -- DiffText, H2 on DiffAdd, H3 on DiffChange. A markdown file therefore
    -- carries the git colours as full-width bars. Clearing the fills leaves
    -- the headings their own foreground and leaves the diff groups alone.
    for level = 1, 6 do
      hl["RenderMarkdownH" .. level .. "Bg"] = { bg = FIELD }
    end

    -- RVS ON: the machine inverts the two screen colours for a selection and
    -- does nothing else. aether tints the line and keeps its foreground.
    local reverse = { fg = "{{ selection_foreground }}", bg = "{{ selection_background }}" }
    for _, group in ipairs({ "Visual", "VisualNOS" }) do
      hl[group] = vim.tbl_extend("force", {}, reverse)
    end
  end
end

local spec = {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = opts,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}

return spec
