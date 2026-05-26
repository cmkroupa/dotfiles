-- Generated dynamically by dotfiles setup.sh
local enabled = {
  "python",
  "rust",
  "c",
  "lua",
  "web",
}

-- ── Mapping ───────────────────────────────────────────────────────────────────
local map = {
  ruby   = { extra_lsp    = { "ruby_lsp" },
             mason_tools  = { "rubocop" } },
  python = { mason_lsp    = { "pyright" },
             mason_tools  = { "black", "ruff" } },
  go     = { mason_lsp    = { "gopls" } },
  rust   = { mason_lsp    = { "rust_analyzer" } },
  lua    = { mason_lsp    = { "lua_ls" },
             mason_tools  = { "stylua" } },
  c      = { mason_lsp    = { "clangd" },
             mason_tools  = { "clang-format" } },
  web    = { mason_lsp    = { "html", "cssls", "emmet_ls" } },
}

local result = { mason_lsp = {}, mason_tools = {}, extra_lsp = {} }

for _, lang in ipairs(enabled) do
  local entry = map[lang] or {}
  for _, s in ipairs(entry.mason_lsp   or {}) do table.insert(result.mason_lsp,   s) end
  for _, s in ipairs(entry.mason_tools or {}) do table.insert(result.mason_tools, s) end
  for _, s in ipairs(entry.extra_lsp   or {}) do table.insert(result.extra_lsp,   s) end
end

return result
