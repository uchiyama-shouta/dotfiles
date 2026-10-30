# AGENTS.md

Nix + home-manager による個人設定管理リポジトリ。

## 検証

- `nix fmt` — nixfmt による整形（formatter は `nixfmt-tree`）。Nix ファイル変更後に必ず実行。
- 検証コマンドは `README.md` の「検証」を参照し、変更に関連するチェックを実行する。CI の全検証は `.github/workflows/check.yml` を参照する。
- 新規ファイルを含めて flake を評価する場合は、README の手順どおり `path:.` を使う。Git ベースの flake では未追跡ファイルが含まれない。

## 構成

- `flake.nix` — `homeConfigurations.shouta-wsl`（home-manager）と `nixosConfigurations.shota-nixos`（NixOS + home-manager モジュール）を定義。
- `hosts/` — ホスト別エントリ。`hosts/common/home-manager.nix` が `../../codex` と `../../opencode` を import する。
- `codex/` — `programs.codex.settings` を編集する。`mutableSettings = true` のため、実運用中の `~/.codex/config.toml` は activation 時にマージされる。settings を変更した場合は `tests/checks.nix` 内の jaq アサーションも更新する。
- `opencode/` — `programs.opencode.settings` を編集する。`OPENCODE_CONFIG` env 経由で `~/.config/opencode/home-manager.json` に反映される。TUI 側の `~/.config/opencode/cli.json`（theme、keybinds など）は非管理で手動編集する。
- `overlays/` — nixpkgs への overlay（codex など）。

## ルール

- `home-manager switch` / `nixos-rebuild switch` はユーザー自身が実行する。AI はコマンドを提案するだけにする。
- グローバル指示は `agents/AGENTS.md` に書く。`codex/default.nix` が `home.file.".codex/AGENTS.md"`、`opencode/default.nix` が `xdg.configFile."opencode/AGENTS.md"` として配備する。
- リポジトリ固有の指示はこのファイルに書く。Codex / OpenCode 双方が読む。

## 通常ワークフロー

1. `settings` の変更 → Codex / OpenCode 関連モジュールを編集。
2. `nix fmt` で整形。
3. README の検証手順から変更に関連するチェックを実行する。
4. 変更内容をユーザーに報告し、`home-manager switch` はユーザーが行う。
