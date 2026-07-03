-- vscode-neovim専用の独立設定ファイル
-- ~/.config/nvim（NvChad本体）とは完全に別管理。
-- ファイルツリー・ファジー検索・LSP・カラースキーム・statusline等はVSCode本体の機能と
-- 重複するため、ここでは導入しない。実際のNeovimによる「モーダル編集の感覚」だけを
-- VSCodeに持ち込むための最小構成。

vim.g.mapleader = " "

local opt = vim.opt
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.wrapscan = true

local map = vim.keymap.set

-- コマンドモードへ（本体のmappings.luaと同じ）
map("n", ";", ":", { desc = "コマンドモードへ" })

-- Escapeへのショートカット（本体と同じ）
map("i", "jk", "<Esc>")
map("i", "jj", "<Esc>")
map("i", "<C-c>", "<Esc>")

-- 折り返し行単位の移動（本体と同じ）
map("n", "j", "gj")
map("n", "k", "gk")

-- 検索ハイライト解除（本体と同じ）
map("n", "<Esc><Esc>", "<cmd>nohlsearch<CR><Esc>")

-- ウィンドウ間移動
-- <C-w>系コマンドはvscode-neovimがVSCodeのエディタグループ移動に自動変換する
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- 保存・終了
-- :w/:wa/:sav は vscode-neovim 1.18.0以降、本物のNeovimの書き込み動作になる
-- :q はvscode-neovim側でVSCodeのタブを閉じる動作に自動変換される
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Close editor" })
map("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and close" })

-- 複数ファイル一括置換のベース（本体と同じ、:argsが設定されている前提）
map("n", "<leader>s", ":argdo %s///ge<Left><Left><Left><Left>", { desc = "Search and replace in args" })

-- ここから先はVSCode専用の対応
-- vimのネイティブ機能では意味を持たない操作（quickfix, ctags等）を、
-- 対応するVSCodeコマンドに require("vscode").action() で直結する
--
-- "vscode"モジュールはvscode-neovim拡張機能が実際にNeovimを起動した時にのみ
-- 利用可能（素のnvimで直接このファイルを読み込んだ場合は存在しない）。
-- pcallで安全に読み込み、VSCode外で実行してもエラーにならないようにする。
local ok, vscode = pcall(require, "vscode")

if ok then
  -- quickfixの代わりにVSCodeの「問題」パネルの次/前へ
  -- 本体側の ]q / [q（quickfix次/前）とキーを揃えて、同じ操作感にする
  map("n", "]q", function() vscode.action("editor.action.marker.next") end, { desc = "Next diagnostic" })
  map("n", "[q", function() vscode.action("editor.action.marker.prev") end, { desc = "Prev diagnostic" })

  -- 定義ジャンプ/戻る
  -- 本体側はLSPの gd（定義）を使う運用のため、同じキーに揃える
  map("n", "gd", function() vscode.action("editor.action.revealDefinition") end, { desc = "Go to definition" })
  map("n", "<C-o>", function() vscode.action("workbench.action.navigateBack") end, { desc = "Navigate back" })
end
