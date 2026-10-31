# dotfiles

NixでツールとNeovimプラグインを固定し、Home Managerでユーザー設定を管理する。
対象はx86_64-linuxのWSL、NixOS。旧PC環境のUbuntuフォールバックは廃止した。
tmuxと独自clipboard設定は提供しない。
Codex、OpenCode、htop、Git、Neovim、Node/Rust、Docker CLI/Composeは共通設定で導入する。
GUI・配信サービスはホスト固有設定とし、Windows端末のフォント設定はdotfilesの管理対象外とする。

Codex CLI と共通設定を `codex/default.nix` の `programs.codex` で管理する。
`mutableSettings = true` により、Home Manager 適用時に宣言した設定を
書き込み可能な `~/.codex/config.toml` へ反映する。通常の `codex` コマンドで利用できる。
Nix に宣言していないプロジェクトの信頼設定などは保持し、Codex 自身に保存させる。
プロジェクト名・パス・信頼設定・認証情報・会話履歴は公開設定に含めない。

入力欄は Enter で改行、Alt+Enter で送信し、ステータス欄にコンテキスト残量を表示する。
共通設定の変更は Nix ファイルを編集して Home Manager を適用し、Codex を再起動する。
TUI で変更した宣言済みの項目は、次の適用で Nix の値に戻る。
Nix の宣言から項目を外しても配置先の値は自動削除されない。配置先のコメントや整形は保持されない。
Windows Terminal の Alt+Enter が端末操作と競合する場合は、端末側の割り当て解除が必要。

読み取り専用 config.toml から初めて移行する場合は、適用前にリポジトリ外へバックアップし、
その内容を保持した通常ファイルに戻しておく。ローカルの信頼設定を失わずに移行できる。
以前の対話 zsh の起動関数を読み込んでいる場合は、適用後に新しいシェルを起動する。

OpenCode と共通設定を `opencode/default.nix` の `programs.opencode` で管理する。
パッケージはflake.lockで固定したnixpkgsの`opencode`を使い、Home Managerのモジュールが
WSL・NixOSの共通設定でこのOpenCode v2を導入する。バージョンはロックファイルで再現できる。
`mutableSettings = true`にして、モデル・プロバイダー・テーマ・認証をNixで固定しない。
モデル・プロバイダー・テーマはOpenCode自身の保存先(`~/.config/opencode/`以下の
書き込み可能なファイル)に保持され、TUIでの変更も保持される。
宣言した共通設定は`OPENCODE_CONFIG`で読み込まれるレイヤに書き出され、
ユーザーのグローバル設定より優先され、プロジェクト設定には優先されない。

`opencode`コマンドで起動する。モデルとプロバイダーの接続は初回起動後に
`opencode auth login`で設定する。認証情報はHome Managerの管理外に保存され、
`opencode models`で利用可能なモデルを確認できる。`opencode upgrade`はflakeで固定した
バージョンと競合するため使わず、バージョン更新はflake.lockのnixpkgs更新で行う。

権限ポリシーは`settings.permission`で宣言し、Home Manager生成時に
パッケージ同梱の設定スキーマ(`validateFiles.config`)で検証される。
リポジトリ内の閲覧・編集は許可し、`.env`系ファイルの読み取りは確認を求める。
shellコマンドは、gitの読み取り操作を含めて複合コマンドやオプション付き実行が
確認から漏れないよう、すべて`ask`とし自動許可を置かない。
`sudo`、`nixos-rebuild switch`、`home-manager switch`は`deny`とし、
エージェントは実行できない。作業ディレクトリ外のアクセスとURL取得
(`webfetch`)も`ask`とする。

この権限はコマンド文字列のパターンマッチであってOSレベルの拘束力はない。
複合コマンドや`sh -c`経由の実行で回避される可能性があり、秘密情報の完全な保護や
ネットワーク通信の分離を保証しない。`--auto`起動時は`deny`以外の`ask`を
自動承認する。プロジェクトの`opencode.json`はこの共通設定より優先されるため、
権限を緩める変更はプロジェクト側でも行わないこと。OSレベルの隔離
(bubblewrapラッパー)は未実装であり、別の段階で設計・検証する。

### WSL の Docker Sandboxes（検証中）

WSL 向け Home Manager に `sbx` を導入し、Nix 開発環境用 Kit を
`~/.config/sbx/nix-kit` に配置する。Kit は Nix 2.35.4 の配布物をハッシュ検証して
Sandbox 内に導入する。ホストのプロジェクトを共有せず、共有 Skills を無効にして作成する：

```sh
sbx settings set ssh.agentForwardingEnabled false
sbx daemon restart
sbx policy init deny-all
sbx create --name my-sandbox --skills off --kit ~/.config/sbx/nix-kit opencode
```

`policy init` は未初期化の場合の一度限りの操作。OpenCode Kit は `deny-all` の上に
複数の通信先を許可する。Nix Kit は未選択のモデルプロバイダーを明示的に拒否する。
`sbx policy ls my-sandbox --wide --type network` で実際のルールを確認する。
別のプロバイダーを使う場合は Kit の拒否ルールを見直し、Sandbox を作り直す。
`sbx run opencode` は作業ディレクトリを既定で共有するため、上記の作成手順を使う。

非公開リポジトリには、対象リポジトリに限定した GitHub の fine-grained token を使う。
`Contents: read` と `Issues: read` を付け、書き込み権限は付けない。ホストの個人用
書き込み認証を渡さず、Sandbox に限定して登録する。token は対話入力し、コマンド引数・
シェル履歴・設定ファイルに書かない：

```sh
sbx secret set github --sandbox my-sandbox
sbx exec my-sandbox sh -c 'cd /home/agent/workspace && git -c credential.helper="!gh auth git-credential" clone https://github.com/OWNER/REPOSITORY.git project'
sbx exec my-sandbox gh issue view ISSUE_NUMBER --repo OWNER/REPOSITORY
sbx exec -it my-sandbox sh /home/agent/nix-opencode.sh /home/agent/workspace/project
```

GitHub の認証は proxy が扱う。Sandbox 内でブランチとコミットを作ったら、例えば次の
ように bundle にまとめてホストへ取り出す。`BRANCH` は Sandbox 内で作成したブランチ名、
`SANDBOX` は Sandbox 名を指定する。bundle にはブランチの Git 履歴が含まれるため、
ホスト上でも非公開リポジトリと同様に扱う：

```sh
sbx exec SANDBOX git -C /home/agent/workspace/project bundle create /home/agent/workspace/result.bundle BRANCH
sbx cp SANDBOX:/home/agent/workspace/result.bundle ./result.bundle
```

ホスト側の隔離したレビュー用 clone で bundle を `git fetch` し、差分とテストを確認してから
ホストの認証で作業ブランチを push・PR 作成する。ホストの元の作業ツリーに直接 fetch する必要はない。
読み取り専用 token の Push は `--dry-run` で 403 を確認したが、GitHub の個別設定や token の
権限は実際に使用するものを確認する。Sandbox に入るコードや Issue は使用するモデルへ送信される。

これは実験段階の構成。OpenCode の無料モデルは利用上限に達する場合がある。今回の検証では
Sandbox 内の Playwright 用 Chromium と crates.io の取得がネットワークポリシーで拒否されたため、
ブラウザテストはホスト側で実施した。WSL 上の Tauri は EGL エラーで描画を確認できていない。
Kit による Nix 環境の作成・非公開リポジトリと Issue の読み取り・コミット回収は検証済みだが、
複数 Issue の並列実行やプロバイダー変更後の構成は未検証。

## 検証

作業中の新規ファイルも評価するため、以下は`path:.`を使用する。

```sh
nix run path:.#formatter.x86_64-linux -- --ci
nix develop path:. --command stylua --check neovim/nvim tests
nix develop path:. --command statix check -o errfmt .
nix flake check path:. --no-write-lock-file
nix build --no-link path:.#homeConfigurations.shouta-wsl.activationPackage
nix build --no-link path:.#nixosConfigurations.shota-nixos.config.system.build.toplevel
```

`nix fmt`でNix、`nix develop --command stylua neovim/nvim tests`でLuaを整形する。
CIは2ホストの評価Warning、ビルド、必須CLI導入、隔離したNeovim・SSH署名・シェルの実動作を検証する。

## ホスト別の導入・適用

WSLではNixのmulti-user環境を先に導入する。ユーザー名とHOMEはホスト設定に合わせる。
WSLは`/etc/wsl.conf`に以下を設定し、Windows側で`wsl --shutdown`して再起動する。

```ini
[boot]
systemd=true
```

`systemctl --user status`が使えることを確認する。WSLのlocaleはOS設定を継承する。
`locale -a`で必要なlocaleを確認し、必要なら`sudo locale-gen ja_JP.UTF-8 en_US.UTF-8`を実行する。

```sh
# WSL (user: shouta)
home-manager switch --flake path:.#shouta-wsl
# NixOS (user: shota)
sudo nixos-rebuild switch --flake path:.#shota-nixos
```

Home Managerが未導入なら、同じflakeに固定された実行ファイルを使う：

```sh
nix run --inputs-from path:. home-manager -- switch --flake path:.#shouta-wsl
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
command -v codex opencode htop nvim git docker
codex --version
opencode --version
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
UbuntuベースのWSLでは[Docker公式のUbuntu導入手順](https://docs.docker.com/engine/install/ubuntu/)に従い、
`docker-ce`、`docker-ce-cli`、`containerd.io`、`docker-buildx-plugin`、`docker-compose-plugin`を導入する。

```sh
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
# 再ログイン後
docker info
docker compose version
```

WSLはLinux側Engineを標準とし、Docker Desktopと二重管理しない。既にDesktopを使う場合は移行前に
コンテナ・volumeを退避する。Nix側はクライアントを提供し、WSLのdaemonはOS側で管理する。
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
