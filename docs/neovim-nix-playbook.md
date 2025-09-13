# Neovim/Nix Setup — Current State & Playbook

*Last updated: 2025-08-29*

## 1) Environment

* **OS**: WSL2 (Linux 6.6)
* **Neovim**: 0.11.1 (Nix / Home Manager + flake)
* **Plugin manager**: lazy.nvim (Nix 提供)
* **Nix**: nixpkgs pinned via `flake.lock`

## 2) Core architecture（再現性の柱）

* **Treesitter**: `pkgs.vimPlugins.nvim-treesitter.withPlugins`（**固定言語セット**）。現在は withPlugins で運用中。

  * `:TSUpdate` や `:TSInstall` は **使わない**（再現性維持）。
  * `lua/plugins/treesitter.lua`:

    * `ensure_installed = {}` / `auto_install = false`
* **lazy.nvim**: Nix 管理の pack/start を**消さない**設定

  ```lua
  require("lazy").setup({
    defaults = { lazy = true },
    spec = "plugins",
    lockfile = vim.fn.stdpath("data") .. "/lazy/lazy-lock.json",
  }, {
    performance = {
      reset_packpath = false,
      rtp = { reset = false },
    },
    install = { missing = false },
  })
  ```
* **packpath**: Home Manager の `programs.neovim.plugins` は **全プラグインを列挙**（packpath が直接原因ではなかったため現状この形でOK）。

  ```nix
  {
    programs.neovim = {
      enable = true;
      plugins = map (p: p.pkg) (lib.attrValues plugins);
    };
    xdg.configFile."nvim".source = nvimWithVars;
  }
  ```

## 3) Plugin set（主なもの）

* **Syntax/TS**: nvim-treesitter（パーサ同梱）
* **UI**: tokyonight.nvim, lualine.nvim, bufferline.nvim, which-key.nvim, devicons
* **Search**: telescope.nvim + telescope-fzf-native.nvim（依存: plenary.nvim）
* **Edit**: nvim-cmp（cmp-nvim-lsp / buffer / path / cmdline / LuaSnip / cmp-luasnip）, Comment.nvimcomment
* **Files**: nvim-tree.lua
* **Format**: conform.nvim（Biome/Prettier/Rustfmt/Taplo/Stylua 等）
* **LSP**: lspconfig（rust-analyzer, tsserver(ts\_ls), html, cssls, jsonls, yamlls, tailwindcss, graphql, bashls, dockerls, clangd, nixd, lua\_ls）
* **Indent/Scope**: hlchunk.nvim（`use_treesitter = true`、角あり枠）
* **Git**: gitsigns.nvim（hunk 操作/行内 blame）＋ diffview\.nvim（差分/履歴 UI）

## 4) hlchunk.nvim（現行設定の要点） hlchunk.nvim（現行設定の要点）

* 角あり箱線でカレントスコープを強調。
* 細線インデント（`│`）。
* 必要に応じて：

  * `exclude_filetypes = { "help", "TelescopePrompt", "lazy", "NvimTree", "neo-tree" }`
  * `max_file_size = 1024 * 1024`（重いファイルでは無効化）

## 5) Options（必要に応じて）

```lua
-- 行番号
vim.opt.number = true
vim.opt.relativenumber = false

-- 左端の余白揺れ防止（gitsigns/diagnostic 用）
vim.opt.signcolumn = "yes"

-- 半角スペース等の可視化
vim.opt.list = true
vim.opt.listchars = { space = "·", tab = "→ ", trail = "•" }
```lua
-- 行番号
vim.opt.number = true
vim.opt.relativenumber = true

-- 半角スペース等の可視化
vim.opt.list = true
vim.opt.listchars = { space = "·", tab = "→ ", trail = "•" }
```

## 6) Operational cheats

* Treesitter が正しく載っているか：

  * `:checkhealth nvim-treesitter`
  * `:lua print(table.concat(vim.api.nvim_get_runtime_file("parser/*.so", false), "\n"))`
* LSP 情報：`:LspInfo`
* Treesitter モジュール情報：`:TSModuleInfo`
* Telescope 依存：`plenary.nvim` が rtp にあるかを `:lua print(vim.inspect(vim.opt.runtimepath:get()))` で確認

## 7) Reproducibility guardrails

* `:TSUpdate` / `:TSInstall` は使わない（ネット取得による汚染防止）。
* lazy の **reset を無効**化（packpath/rtp）。
* Nix による **パッケージ pin**（flake.lock 管理）。

## 8) Backlog（後で入れる候補）

* `windwp/nvim-ts-autotag`（HTML/TSXの自動タグ）
* `rafamadriz/friendly-snippets`（LuaSnip 用スニペット集）
* `dmmulroy/ts-error-translator.nvim`（TS エラー翻訳）
* `roobert/tailwindcss-colorizer-cmp.nvim`（Tailwind補完に色チップ）
* Git 体験：`lewis6991/gitsigns.nvim` + `sindrets/diffview.nvim`
* API クライアント：`rest-nvim/rest.nvim`

## 9) Treesitter 設定（現在）

`withPlugins` で固定言語セットを同梱：

```nix
nvim-treesitter = {
  name = "nvim-treesitter";
  dirVar = "nvim_treesitter";
  pkg = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
    rust typescript tsx javascript html css toml json yaml
    bash nix c lua vim vimdoc markdown markdown_inline
  ]);
};
```

## 10) How-to: Nix + lazy.nvim にプラグインを追加する流れ

1. `neovim/plugins.nix` に `dirVar` と `pkg` を追加。
2. `lua/plugins/<name>.lua` に Lazy 仕様のテーブルを置く（`dir = "@dirVar@"`）。
3. `home-manager switch` 後に `:Lazy` で読み込み確認。

---

これをベースに「軽量化（withPlugins化）」「スニペットやGit体験の追加」を順次進めれば、再現性を保ちつつ拡張できます。

## 11) Clipboard（クロス環境対応）

* **目的**: `… | clip` / `pasteclip` をどの環境でも同じ操作で使う。
* **導入（Home Manager）**: `wl-clipboard`, `xclip`, `xsel` をインストールし、ラッパー `clip` / `pasteclip` を提供。
* **優先順**:

  1. **Wayland** → `wl-copy` / `wl-paste`
  2. **X11** → `xclip`（なければ `xsel`）
  3. **OSC52** フォールバック（端末/SSH/tmux 経由でコピー）
* **使い方**:

  * `git diff | clip`
  * `printf 'hello
    ' | clip`
  * `pasteclip`
* **メモ**:

  * tmux を使う場合は `.tmux.conf` に `set -g set-clipboard on` を推奨。
  * **WSL 向けフォールバックは含めない**（Linux/Ubuntu 前提）。

### TODO（Clipboard）

* `clip` / `pasteclip` を **Rust 実装**に置き換える（仮称: *clip-bridge*）。

  * 優先順（Wayland → X11 → OSC52）と CLI 互換（コマンド名・主なフラグ）を維持。
  * flake に組み込み、**Nix で pin** して配布。

---

## 12) Git — current state & must‑dos

* **状態**: Git は Home Manager 管理。`delta` 組み込み済み、`gh` 連携、`ssh-agent` 有効、GitHub 用 `Match github.com` 設定済み。
* **必須の推しポイント**:

  * `vim.opt.signcolumn = "yes"` を設定済み（左端のガタつき防止）。
  * `gh config get git_protocol` が `ssh` であること（済）。
  * `ssh -T git@github.com` で疎通確認（済）。
* **Git 署名（SSH）**: 現在は **TODO として保留**。Git 2.49 で使えるが、鍵・Agent 運用の方針決めてから固める。

### gitsigns.nvim（要点）

* 読み込み: `BufReadPre/BufNewFile`
* 主なキー: `]h` / `[h`（hunk 移動）, `<leader>gs`（stage hunk）, `<leader>gr`（reset hunk）, `<leader>gB`（toggle blame）

### diffview\.nvim（要点）

* コマンド: `DiffviewOpen`, `DiffviewFileHistory` など
* 主なキー: `<leader>go`（open）, `<leader>gq`（close）, `<leader>gh`（file history）

---

## 13) Bootstrap（新しいマシンでの初期セットアップ）

1. **Nix / Home Manager を導入**（公式手順に従う）。Flakes を有効化。
2. リポジトリを clone：`git clone git@github.com:<you>/dotfiles.git`。
3. 適用：`home-manager switch --flake .#shouta`。
4. **SSH**：必要なら鍵作成 `ssh-keygen -t ed25519 -C "<mail>" -f ~/.ssh/id_ed25519_github` → `ssh-add -t 8h ~/.ssh/id_ed25519_github` → `gh auth login -p ssh -h github.com`。
5. 検証：`ssh -T git@github.com` / `git show`（delta 表示）/ `nvim` → `:checkhealth nvim-treesitter`。
