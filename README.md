# dotfiles

NixでツールとNeovimプラグインを固定し、Home Managerでユーザー設定を管理する。
対象はx86_64-linuxのWSL、Ubuntu、NixOS。tmuxと独自clipboard設定は提供しない。
Codex、htop、Git、Neovim、Node/Rust、Docker CLI/Composeは共通設定で導入する。
GUI・配信サービスはホスト固有設定とし、Windows端末のフォント設定はdotfilesの管理対象外とする。

## 検証

作業中の新規ファイルも評価するため、以下は`path:.`を使用する。

```sh
nix run path:.#formatter.x86_64-linux -- --ci
nix develop path:. --command stylua --check neovim/nvim tests
nix develop path:. --command statix check -o errfmt .
nix flake check path:. --no-write-lock-file
nix build --no-link path:.#homeConfigurations.shouta-wsl.activationPackage
nix build --no-link path:.#homeConfigurations.shota-ubuntu.activationPackage
nix build --no-link path:.#nixosConfigurations.shota-nixos.config.system.build.toplevel
```

`nix fmt`でNix、`nix develop --command stylua neovim/nvim tests`でLuaを整形する。
CIは3ホストの評価Warning、ビルド、隔離したNeovim・SSH署名・シェルの実動作を検証する。

## ホスト別の導入・適用

Ubuntu/WSLではNixのmulti-user環境を先に導入する。ユーザー名とHOMEは各ホスト設定に合わせる。
WSLは`/etc/wsl.conf`に以下を設定し、Windows側で`wsl --shutdown`して再起動する。

```ini
[boot]
systemd=true
```

`systemctl --user status`が使えることを確認する。Ubuntu/WSLのlocaleはOS設定を継承する。
`locale -a`で必要なlocaleを確認し、必要なら`sudo locale-gen ja_JP.UTF-8 en_US.UTF-8`を実行する。

```sh
# WSL (user: shouta)
home-manager switch --flake path:.#shouta-wsl
# Ubuntu (user: shota)
home-manager switch --flake path:.#shota-ubuntu
# NixOS (user: shota)
sudo nixos-rebuild switch --flake path:.#shota-nixos
```

Home Managerが未導入なら、同じflakeに固定された実行ファイルを使う：

```sh
nix run --inputs-from path:. home-manager -- switch --flake path:.#shota-ubuntu
```

適用後はログアウト・ログインする。NixOS新規導入では実機のhardware設定を生成し、ローカルコンソールで
`sudo passwd shota`を実行する。SSH serverは既定で有効にしない。
`system.stateVersion = "25.11"`と`home.stateVersion = "23.05"`は更新時にも変更しない。

### WSLでのシェルとuser serviceの準備

Home Managerはzshを導入・設定するが、OSアカウントのログインシェルは変更しない。
初回switch後、導入したzshをログインシェルに設定する：

```sh
dotfiles_zsh="$(command -v zsh)"
grep -Fxq "$dotfiles_zsh" /etc/shells || printf '%s\n' "$dotfiles_zsh" | sudo tee -a /etc/shells
chsh -s "$dotfiles_zsh"
```

WSLのセッションを終了し、Windows側で`wsl --shutdown`して起動し直す。
端末側でbashを明示起動している場合は、その起動設定も見直す。
次でzshとsystemd user sessionを確認する：

```sh
getent passwd "$USER"
ps -p $$ -o comm=
systemctl --user status ssh-agent.service
command -v codex htop nvim git docker
codex --version
```

SSH鍵はWSL側にも配置し、初回の対話zshで解除する。GitHub認証はホストごとに`gh auth login`で設定する。
Docker daemonの準備は後述の手順に従う。GUI autostartがないWSL端末でも、鍵解除はTTYから実行できる。

## SSH認証とGit署名

自分の秘密鍵と公開鍵を`~/.ssh/id_ed25519_github`、`~/.ssh/id_ed25519_github.pub`に配置する。
秘密鍵はリポジトリに入れない。`.ssh`は700、秘密鍵は600にする。

systemd userの`ssh-agent.service`を使い、GUI・端末が`$XDG_RUNTIME_DIR/ssh-agent`を共有する。
GUIはログイン時、端末のみの環境は初回の対話シェルでパスフレーズを入力する。
agent停止まで鍵を保持する。入力キャンセル後は`ssh-unlock`で再試行する。

```sh
ssh-unlock
ssh-add -l
git verify-commit HEAD
```

既存のkeychain agentは自動終了しない。切り替えは再ログインで行う。
SSH署名はHTTPSの`gh auth login`とは別に鍵解除が必要。
allowed signersファイルは公開鍵から`~/.local/state/git/allowed_signers`に生成する。

## Docker

NixOSではdaemonとユーザーのdockerグループ所属を宣言済み。適用後の再ログインが必要。
Ubuntu/WSLでは[Docker公式のUbuntu導入手順](https://docs.docker.com/engine/install/ubuntu/)に従い、
`docker-ce`、`docker-ce-cli`、`containerd.io`、`docker-buildx-plugin`、`docker-compose-plugin`を導入する。

```sh
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
# 再ログイン後
docker info
docker compose version
```

WSLはLinux側Engineを標準とし、Docker Desktopと二重管理しない。既にDesktopを使う場合は移行前に
コンテナ・volumeを退避する。Nix側はクライアントを提供し、Ubuntu/WSLのdaemonはOS側で管理する。
dockerグループはホスト管理権限相当なので、追加対象は自分の開発ユーザーに限定する。

`dc`=`docker compose`、`dcup`=起動、`dcdown`=通常停止。
`dcex SERVICE [COMMAND [ARG...]]`は省略時に`sh`を起動する。
volume/imageの削除は確認付き`dcpurge`だけで行う。

## Sunshine (NixOS)

GUIログイン時に起動。KMS captureのためCAP_SYS_ADMINとuinputを使用する。
配信は192.168.3.0/24のみ、管理画面は`https://localhost:47990`のみ、UPnPは無効。
LANが変わった場合はホスト設定の許可ネットワークを更新する。

適用前に`~/.config/sunshine`を権限700のバックアップディレクトリへコピーする。
宣言設定が優先されるため、従来の`sunshine.conf`で変更していた項目はNix設定へ移す。
アプリ一覧とpairing情報は既存のユーザーディレクトリを維持する。
適用後、Moonlightから映像・音声・入力を確認する。

## 開発ツールとロールバック

プロジェクトの`nix develop`、ローカルNode依存、`rust-toolchain.toml`を優先する。
グローバルツールは補助用。asdfは管理しない。Neovimの詳細は[playbook](docs/neovim-nix-playbook.md)を参照。

適用前の世代を`home-manager generations`または`sudo nix-env --list-generations -p /nix/var/nix/profiles/system`で記録する。
Home Managerは前世代の`activate`を実行、NixOSは`sudo nixos-rebuild switch --rollback`で戻す。
起動に失敗した場合はboot menuから前世代を選択する。

監査と対応状況は[監査レポート](docs/dotfiles-audit-2026-10-07.md)に記録する。
