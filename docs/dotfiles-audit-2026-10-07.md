# dotfiles 監査（2026-10-07）

初回監査の対象コミット: `5e57162`。初回監査では設定変更・switch・rebuild・鍵追加・Gitリモートへの書き込みは実施していない。後続の実装修正は末尾の対応表に記録する。

## 結論

Nixの構文やホストの評価が全面的に壊れているわけではない。3ホストの評価は成功した。一方、更新された依存パッケージと古い設定APIの不整合、SSH agentへの鍵登録不足、宣言されていない外部ツールへの依存がある。Nix評価成功だけでは日常操作の正常性を保証できない構成になっている。

優先度は P1=早期修正（実害または状態移行リスク）、P2=機能不良・将来破損・再現性不足、P3=保守改善。以下の「確認済み」は実行または設定・同梱ソースで確認できたもの。「条件付き」は発生条件を記載したもの。全操作・全端末の正常性を保証する監査ではない。

## 実施した検証と限界

| 検証 | 結果 |
| --- | --- |
| 全追跡設定ファイルの確認 | Nix、Lua、Zsh、tmux、Git、README、lock、overlayを確認 |
| NixOS `system.build.toplevel.drvPath` のoffline評価 | 成功。下記Warningを再現 |
| WSL・Ubuntu `activationPackage.drvPath` のoffline評価 | 両方成功。下記Warningを再現 |
| `nix flake check --offline --no-build --no-write-lock-file` | x86_64-linuxで成功。別systemは省略された |
| `statix check -o json .` | 括弧・属性のまとめ方に関するスタイル警告のみ。実害とは区別 |
| `zsh -n shell/.zshrc` | 構文は成功。外部コマンドやsource先の存在は別問題 |
| Luaファイルのloadfileによる構文確認 | 成功 |
| 適用済みNeovim設定とリポジトリの比較 | Nix storeへの変数置換を正規化すると全ファイル一致 |
| Neovimを隔離したXDGディレクトリで起動・Luaファイルを開く | Treesitter設定エラーとLSP非推奨警告を再現 |
| lazyに登録された27プラグインの明示ロード | 実施。which-key初期化漏れを確認。全操作の動作確認ではない |
| Telescope fzf拡張のロード | 成功 |
| 設定中の主要LSP/formatterコマンドの存在確認 | 現ホストで欠落なし |
| SSH agent登録状況と`ssh -G github.com` | agentに鍵なし。設定展開は成功 |
| Git ignoreの実効値 | Cargo.lock、flake.lock、pnpm-lock.yaml、.env.exampleが除外される |
| SvelteファイルをグローバルPrettierで処理 | `No parser could be inferred`を再現 |
| clipのtmux分岐をバイト列確認 | 内側ESCが二重化されていない |

現ホストはNixOS、Neovim 0.12.2。WSL・Ubuntuは評価のみで、現地での起動・適用は未検証。フルビルド、再起動、実際のpush/commit署名、GUI端末でのOSC52転送、プロジェクト別LSP機能・formatterの全言語検証は実施していない。公開鍵・秘密鍵の内容は出力していない。

最初にサンドボックス内で出たSSHの `Bad owner or permissions` は、Nix store所有者が `nobody` に見える制限の影響。制限外では同じファイルがroot所有でSSH設定展開も成功したため、dotfilesの不具合には数えない。agentソケットやNix daemonへの接続拒否も同様に切り分けた。

## P1: 優先して直す事項

### 1. Treesitterの新旧API不整合（確認済み）

場所: `neovim/nvim/lua/plugins/treesitter.lua:4-15`。

Luaファイルを開くと以下が出る。

```text
Failed to run `config` for nvim-treesitter
module 'nvim-treesitter.configs' not found
```

適用済みプラグインは `nvim-treesitter-0.10.0-unstable-2026-04-03`。同梱READMEは互換性のない新版を説明しており、旧 `configs.setup` は存在しない。また新版はlazy-loadingをサポートしないが、設定は `BufReadPre` / `BufNewFile` で遅延ロードしている。

新APIへの移行と常時ロード、FileTypeでのhighlight/indent有効化をセットで行う必要がある。パーサは引き続きNixで管理する。上流の `TSUpdate` 推奨をそのままNix storeに対して実行するのは避ける。API呼び出しだけ消すと、期待したhighlightやindentが有効にならない。

一次資料: [Treesitter README](https://github.com/nvim-treesitter/nvim-treesitter)。判定には最新Webだけでなくインストール済みREADMEを使用した。

### 2. Git SSH署名と鍵キャッシュの接続不足（設定と現状を確認、反復入力の全経路は未再現）

場所: `git.nix:36-40,79-92`、`shell/.zshrc:27`。

commit/tagの署名が常時有効で、署名鍵に `~/.ssh/id_ed25519_github.pub` を指定している。一方、keychain呼び出しには登録する鍵名を渡していない。現プロセスのSSH agentは `The agent has no identities.` だった。NixOSの `programs.ssh.startAgent` もfalseで、このリポジトリはGUI起動のGitやエディタに同じagentを渡す仕組みを宣言していない。

`AddKeysToAgent yes` はSSH接続で利用した鍵をagentに登録する設定で、Gitの `ssh-keygen -Y sign` による署名時の登録を保証しない。HTTPSリモートやローカルcommit中心の利用では、GitHubへのSSH接続による登録自体が起こらない。`gh auth git-credential` はHTTPS認証用なので署名鍵のパスフレーズをキャッシュしない。

持続するagentを一つに決め、対象鍵を明示して登録し、シェル・GUI・tmuxで同じソケットを参照させる。`keychain --quiet --eval id_ed25519_github` はシェル利用の改善候補だが、GUIへの環境伝播も別途必要。署名機能を無効化することが必須ではない。初回unlock後にcommit/tagとSSH接続の双方で反復入力が消えるか確認する。

一次資料: [GitのSSH署名設定](https://git-scm.com/docs/git-config)、[OpenSSH AddKeysToAgent](https://man.openbsd.org/ssh_config#AddKeysToAgent)。

### 3. `system.stateVersion` 未設定（確認済み）

場所: `hosts/shota-nixos/configuration.nix`。

評価で `system.stateVersion is not set, defaulting to 26.05` が出る。将来nixpkgsを更新すると、永続データやサービスの互換性に関わる既定値が意図せず変わり得る。

初期導入時の世代を確認して明示する。現行releaseの値を機械的に書くのは適切ではない。Home Managerの `home.stateVersion = "23.05"` は別の設定であり、単に古いという理由で上げるべきではない。

### 4. 全リポジトリでlockfileを無視（確認済み）

場所: `git.nix:57-68`。

`*.lock` と `*-lock.*` が、Cargo.lock、flake.lock、pnpm-lock.yamlなどをグローバルに無視する。新規プロジェクトで依存固定ファイルを気づかず未追跡にし、再現性・レビューを損なう。既に追跡済みの本リポジトリのflake.lockはこの設定では消えない。

lockfile除外はグローバルから外し、必要な例外だけ各プロジェクトで決める。`.env.*` は `.env.example` も除外するため、共有用サンプルの扱いも併せて見直す。

## P2: 機能不良・潜在的な破損

### 5. Neovimの貼り付けが常に空（確認済み）

場所: `neovim/nvim/lua/config/options.lua:67-83`。

clipboardを `unnamed,unnamedplus` にしながら、両レジスタのpaste関数が常に `{ "" }, "v"` を返す。外部クリップボード読み込みができないだけでなく、通常のpもクリップボード経由で空になり得る。

OSC52でコピーのみ行うなら、通常レジスタでのyank/pasteを維持する設定にする。外部貼り付けは端末のpasteまたは利用環境のclipboard providerに任せる。

### 6. which-keyが初期化されない（確認済み）

場所: `neovim/nvim/lua/plugins/which-key.lua:6-15`。

独自 `config` があるためlazyによる `opts` の自動setupが実行されない。関数内も `wk.add` だけで `wk.setup` がない。明示ロード後も `did_setup=false` を確認。`setup(opts)` してからaddする必要がある。

### 7. Svelte保存時のPrettierエラー（単独環境で再現、プロジェクト依存）

場所: `neovim/nvim/lua/plugins/format.lua:18`、`neovim/tools.nix:27`。

グローバルPrettier単体にはSvelte parserがなく、最小Svelteファイルで `No parser could be inferred` が出る。プロジェクト側のPrettier/Svelteプラグイン設定がある場合は動く可能性があるが、dotfiles単体での保証がない。

ローカルのPrettierと `prettier-plugin-svelte` を使う方針、またはSvelte LSPへのfallback方針を明示する。formatter不在・失敗とLSP fallbackの挙動は実保存で確認する。

### 8. LSP設定APIが非推奨（再現済み）

場所: `neovim/nvim/lua/plugins/lsp.lua:9-109`。

`require('lspconfig')` のsetupフレームワークが非推奨で、適用済みnvim-lspconfig 2.8.0はv3での削除予告を出す。現時点で警告だけの箇所を、LSP全体が既に停止しているとは判定しない。`vim.lsp.config` / `vim.lsp.enable` へ移行する。

一次資料: [nvim-lspconfigの移行案内](https://github.com/neovim/nvim-lspconfig)。

### 9. LSP依存・attach処理の不足（設定確認、発生は条件付き）

場所: `neovim/nvim/lua/plugins/lsp.lua:8,61-70`、`config/lsp_keymaps.lua:15-25`。

`cmp_nvim_lsp` をrequireするが、LSP spec自体にはdependencies宣言がない。現環境では全プラグインをNix側にも登録しているためロードできたが、ロード経路に依存する。依存をLSP specに明示する。

html/css/json/yaml/tailwind/graphqlには共通on_attachがなく、他言語と独自キー・診断popup・inlay hintの挙動が異なる。共通 `LspAttach` に寄せると漏れを防げる。on_attachは接続のたびにCursorHold autocmdを追加するため、複数clientや再接続で重複し得る。augroup等で重複を避ける。inlay hintの有効化も対応clientを確認する。

### 10. 意図しない自動保存と失敗の隠蔽（設定確認）

場所: `neovim/nvim/lua/config/options.lua:11-21,41-60`、`plugins/format.lua:33`。

BufLeaveでupdate、FocusLostでwall、autowrite/autowriteallがすべて有効。別バッファへの移動やウィンドウ切替だけで編集中のファイルが保存され、formatterも動く。`silent!` によって書き込み失敗を見落としやすい。これは必ずバグというわけではないが、ユーザーが意図を確認すべき動作。

保存方式を一つに整理し、失敗は通知する。formatterの1秒timeoutは大きなファイルやcold startで不足し得る。末尾空白除去はmarkdown以外の全filetype対象なので、空白が意味を持つテストデータ等にも作用する。

### 11. Zsh起動時に存在しないasdfを無条件source（現ホストで確認済み）

場所: `shell/.zshrc:17`。

`~/.asdf/asdf.sh` が存在しないのにsourceしている。asdfはNixで宣言されてもいない。削除するか、存在チェックと導入方針を明示する。moon/fzfも外部導入前提の残りがある（fzfのsource自体は存在チェック済み）。

### 12. compinit二重実行と初回起動の不備（設定・生成物を確認）

場所: `shell/.zshrc:1-10`、`shell/zsh.nix:4-10`。

Home Manager生成 `.zshrc` が既にcompinitを実行した後、追加設定で再実行している。dumpファイルを固定の `~/.zcompdump` で参照する点もHM側設定と結合していない。新規HOMEでファイルがない場合 `date -r` が失敗する。

補完初期化はHome Managerに任せるか、HMの自動初期化を無効にした上で一箇所にまとめる。自前キャッシュ判定を残す場合は初回とdumpパスを扱う。

### 13. localeの不整合（設定確認、非NixOSホストでは条件付き）

場所: `shell/.zshrc:12-13`、`hosts/shota-nixos/configuration.nix:10`。

NixOSのja_JP指定に対し、シェルではLC_ALL/LANGをen_USで強制。LC_ALLは個別locale設定まで上書きする。Ubuntu/WSLにen_US.UTF-8が生成されていなければ警告の原因になる。LANGと必要なLC_*をホスト方針に沿って設定する。

### 14. Docker aliasの実行環境と引数処理（欠落確認）

場所: `shell/alias.nix:2-6`。

aliasはdocker-composeを使うが、Docker本体・Composeはこのリポジトリで導入されておらず、現ホストでも両コマンドが見つからない。Dockerを使うならホスト側のdaemonとCLIを含めて導入し、Compose v2を選ぶ場合は `docker compose` に合わせる。

`dcex` は `$1` / `$2` を引用せず、コマンド引数を一つの文字列として安全に渡せない。またコンテナにashがある前提。関数として引数を適切に処理する。`dcdown` はvolumeとimageを削除するため、日常停止用とデータ削除用の名前を分けるのが望ましい。

### 15. tmux用OSC52転送のエスケープ不足（バイト列確認、端末での実害は未検証）

場所: `shell/clipboard.nix:10-11`、`tmux.nix:28-31`。

tmuxのDCS passthroughに入れる内側ESCが一つで、必要な二重化をしていない。またcopy-pipeで起動したclipの標準出力が端末まで届く前提も検証されていない。`allow-passthrough` の設定もない。

tmux自身のclipboard転送を使うか、正しいpassthroughと出力先を設計する。ローカル・SSH・tmux・入れ子tmuxごとに端末で検証する。端末依存のため、現時点で全環境のコピー失敗とは断定しない。

### 16. Sunshineの権限・公開範囲（設定確認、利用意図の確認対象）

場所: `hosts/shota-nixos/configuration.nix:36-40`、`hardware-configuration.nix:41`。

Sunshineが自動起動、firewall開放、CAP_SYS_ADMIN付与、uinput有効化されている。画面・入力を扱うサービスとして利用意図があるなら必要な設定の可能性があるが、一般的なdotfilesとしては大きな権限。不要なら無効化し、必要ならLAN/VPNなど実際の接続範囲と権限を確認する。インターネットからアクセスできることや脆弱性の存在は未確認。

### 17. NixOS新規導入の不足（設定確認、既存端末は別）

場所: `hosts/shota-nixos/configuration.nix:21-26`、`hardware-configuration.nix:16-25`。

ユーザーの初期パスワード・認証鍵がなく、SSH serverも評価結果では無効。既にパスワードを設定した端末では問題ないが、この設定単独をクリーン端末へ適用しても初回ログイン方法は用意されない。秘密をNixへ直書きせず、初回セットアップ手順を記載する。

root/bootのUUIDとIntel向けkernel設定は特定実機専用。別端末への流用ではhardware設定を再生成する必要がある。GRUBの `/dev/null` はGRUB無効時には直ちに障害ではないが、不要なダミー設定として除去候補。

## 再現したNix Warningの一覧

これらはstatixのスタイル警告とは別の、実際のNix評価Warning。

| 設定 | 状態・修正方向 |
| --- | --- |
| `programs.git.userName` | `programs.git.settings.user.name`へ |
| `programs.git.userEmail` | `programs.git.settings.user.email`へ |
| `programs.git.extraConfig` | `programs.git.settings`へ |
| `programs.git.aliases` | `programs.git.settings.alias`へ |
| `programs.git.delta.enable/options` | `programs.delta.enable/options`へ |
| delta Git連携 | `programs.delta.enableGitIntegration = true`を明示 |
| SSHの暗黙default | `enableDefaultConfig` と必要な `matchBlocks."*"` を明示 |
| Neovim Python3/Ruby provider | 古いstateVersionにより旧defaultを維持。利用有無を決め明示 |
| Firefox `configPath` | 旧defaultを維持。既存profileの位置を保つか、移行手順付きで変更 |
| `nixfmt-classic` | deprecated/unmaintained。flake formatterとtoolsをnixfmtへ移行 |
| `dockerfile-language-server-nodejs` | `dockerfile-language-server`へ改名 |
| NixOS `system.stateVersion` | 未設定。導入時の値を確認して固定（P1） |

Warningを消す目的だけでstateVersionを上げたりFirefoxのprofileパスを変更すると、別の移行問題を作る。名称移行とデータ移行は区別して行う。

## P3: 保守・検証の改善

### 18. READMEのWSLコマンドが誤り（確認済み）

`README.md:3` の `.#shouta` は出力に存在しない。正しくは `.#shouta-wsl`。NixOSの適用・初期導入・鍵導入手順も記載されていない。

### 19. Neovim playbookが現状と不一致（確認済み）

`docs/neovim-nix-playbook.md` はNeovim 0.11.1、旧Treesitter API、tokyonight、lazy.setupの旧例を説明している。現構成は0.12.2、新Treesitter、nightfox/carbonfox。旧ドキュメントを修復時の正解として使うと再度破損し得る。

### 20. プラグイン管理の責務が二箇所（構造確認）

`neovim/default.nix` が全プラグインをNeovimのpackへ登録し、Lua側もlazyで登録する。Nixが取得・固定しlazyがロードする設計自体は成立するが、依存・ロード順・pluginスクリプト実行の責務が分かりにくい。`plugins.nix` とLuaの対応も手動管理。

今回、変数置換漏れやTelescope fzfバイナリ欠落は確認されなかった。`telescope.lua` の `build = "make"` はNixでビルド済みのstoreに対して不要で、手動Lazy build時の書き込み失敗候補。Nix側ビルドへ統一する。`pcall` だけで失敗を黙殺する設定も、必要な機能には通知を付ける。

### 21. flake checkに実動作チェックがない（確認済み）

flakeに独自checksやCIがなく、今回もflake checkが成功した状態でTreesitterエラーが発生した。少なくとも3ホストの明示評価と、Neovimのファイルopen・InsertEnter・保存・plugin設定エラーを検知するsmoke checkを追加すると有効。lazyは設定エラーを捕捉するため、Neovimプロセスの終了コードだけでは合否判定できない。

今回のflake checkは他systemを省略しており、portable性を保証していない。宣言されたhome/NixOSホストはすべてx86_64-linux、独自overlayもmetaでx86_64-linuxに限定されている。

### 22. ホスト間の重複とツールバージョン方針（確認済み）

3つのhome-manager.nixに共通imports・packages・ユーザー設定が重複しており、修正漏れを起こしやすい。共通モジュールとホスト差分へ分ける余地がある。グローバルRust/Node/Biome等はflake.lockで固定されるが、プロジェクト固有バージョンと一致する保証はない。asdf残骸を含め、グローバルツールとdevShell/local依存の優先順位を明示する。

rust-overlayには別nixpkgs入力が残る。`follows` は構成簡略化の候補だが、現評価は成功しており、不整合を実証したものではない。無条件に変更しない。

独自Codex overlayはバージョン・ハッシュを固定しており、今回ハッシュ不一致や起動失敗は実証していない。更新時にはnpm package構成・同梱バイナリ・対象OSでの起動検証が必要。この監査では再ビルドや製品機能の確認をしていない。

### 23. その他の運用上の注意（設定確認、利用方針次第）

`fetch.pruneTags = true` はリモートから消えたタグだけでなく、そのリモートにないローカルタグの削除にも関係するため、複数リモートやローカル専用タグを使う場合は見直す。`gpg.ssh.allowedSignersFile` は設定されておらず、ローカルでSSH署名を信頼判定する運用は未整備（GitHubでの署名表示とは別）。

## 修正順序

1. Treesitterを現バージョン対応へ移行し、ファイルopen時のエラーを解消。
2. agentのライフサイクル・鍵登録・GUI/tmuxへの環境伝播を統一。
3. 導入履歴からsystem.stateVersionを固定し、グローバルlockfile除外を解消。
4. clipboard、which-key、Svelte formatter、asdf source、compinitを修正。
5. Home Managerの旧option、LSP旧API、formatterの名称を移行。
6. Sunshine・自動保存・破壊的aliasの利用方針を整理。
7. 共通化とドキュメント更新、実動作チェックを追加。

構成を全面的に書き直す前に、再現した問題から小さく直し、ホスト評価と実動作の両方で確認するのが妥当。

## 実装修正の対応表

ユーザー指定によりtmuxと独自clipboard機能は修復ではなく廃止した。
この表は実装・自動検証と、ログインや別実機を必要とする確認を区別する。

| 項目 | 対応 |
| --- | --- |
| 1 Treesitter | 新API、常時ロード、FileTypeのhighlight/indent、Nix parser/queryの明示runtimepath。全18言語のparserをテスト |
| 2 SSH署名/agent | systemd user agentと共通socketへ統一。GUI/TTY初回解除、排他制御、キャンセル後の明示retry。隔離鍵で署名・反復利用をテスト。実鍵のログイン確認は別途必要 |
| 3 stateVersion | `/etc/nixos/configuration.nix`で確認した導入時の25.11を固定 |
| 4 ignore | lockfile除外を削除し、.envの共有用example/sample/templateを例外化。Git実効値をテスト |
| 5 clipboard | Neovimの上書きを全削除。通常レジスタのyank/pasteをテスト |
| 6 which-key | setupを明示し、初期化をテスト |
| 7 Svelte整形 | グローバルPrettier呼び出しを除去し、同梱LSPのformatterへ移行。実LSPによる編集結果をテスト |
| 8 LSP API | vim.lsp.config/enableへ移行。診断移動・gitsignsも現APIへ移行 |
| 9 LSP attach | cmp依存を明示、全client共通のLspAttach、対応client限定のinlay hint。autocmd重複と共通キーをテスト |
| 10 自動保存 | 明示保存のみ。汎用空白除去を削除、formatter timeoutを3秒へ。移動/FocusLostで保存されないことをテスト |
| 11 asdf | 無条件sourceを削除。moonは存在時のみPATH追加、fzfはNixで管理 |
| 12 compinit | 自前初期化を削除し、Home Managerへ統一 |
| 13 locale | シェルの強制上書きを削除、ホスト設定を継承。Ubuntu/WSLの導入手順を追記 |
| 14 Docker | NixOS daemon、全ホストCLI、Compose plugin方式へ統一。安全なdcdown、確認付きdcpurge、引用を保持するdcex。引数テスト。Ubuntu/WSL daemonは導入手順を整備 |
| 15 tmux/OSC52 | モジュール、import、ta/clip、OSC52、関連playbookを削除 |
| 16 Sunshine | 常時起動/KMS権限を維持、現在のLAN限定、localhost管理画面、UPnP無効。既存locale=jaを引き継ぐ。映像/音声/入力は実機検証待ち |
| 17 初期導入 | 認証の初期設定・hardware再生成を文書化。実機UUIDを維持、GRUBのダミーを除去 |
| 18 README | WSL出力名を修正、3ホスト導入/適用/認証/Docker/rollbackを記載 |
| 19 playbook | 現APIと管理構成に更新。廃止機能の導入手順を削除 |
| 20 plugin責務 | Nix生成manifestへ統一。lazyだけでpluginをロード、TSデータは明示追加。不要なbuildとエラー黙殺を除去。独自init.luaとHMの衝突をsideloadで回避 |
| 21 checks/CI | flakeのNeovim・shell/Git・Codex実動作checks、3ホスト評価/ビルドとWarning検出のGitHub Actionsを追加 |
| 22 重複/バージョン | 共通HMモジュール抽出、プロジェクトツール優先を文書化。rust-overlay入力を維持。Codexは固定バージョンの起動をテスト |
| 23 Git運用 | pruneTags無効、公開鍵からallowed signersを生成。ローカル専用タグの保持と署名検証をテスト |

Home Manager旧オプション、provider/default変更、旧formatter/LSPパッケージ名のWarningを解消し、statixのスタイル指摘も解消した。
flake.lockは変更していない。Composeは固定nixpkgsの現行plugin版を使用する（`docker compose`インターフェース）。

### 実機で残る確認

- NixOS適用後の再ログインと、GUI・端末で実鍵を共有してcommit/tag時に再入力されないこと。
- Docker daemonと、再ログイン後のdockerグループによる利用。
- SunshineのLANクライアントでの映像・音声・入力、および管理画面のリモート拒否。
- Ubuntu/WSLでの実際の適用・systemd user session・Docker daemon導入。

別ホストや対話ログインの確認を、自動テストの成功で代用したとは扱わない。GitHub Actions自体もpush後に実行される。

### 最終検証結果（2026-10-07）

- NixOS、Ubuntu、WSLの全3構成をビルド成功。
- Neovim、shell/Git、Codexの全3 checksを明示ビルドし成功。
- 最終`nix flake check path:. --no-write-lock-file`成功。ホスト別のoffline評価もstderrが空で、Warningなし。
- Nix/Luaの整形、statix、shellcheck、`git diff --check`成功。
- flakeのsystem出力は、実際に管理している`x86_64-linux`に限定。未対応Darwinの評価による非推奨Warningも除去。
- 初回検証時はsudo認証が必要なためswitchを見送った。その後ユーザーがSunshineバックアップ・switch・再ログインを実施し、ビルド済み世代への適用を確認した。
- 再ログイン後、SSH agentとSunshineのuser service、Docker daemonがactiveで、user serviceの失敗はなし。実鍵による連続2回のcommitが再入力なしで成功し、署名検証も成功。dockerグループ所属と一般ユーザーでのdaemon接続も確認した。

実機適用はREADMEのSunshineバックアップと世代記録を済ませてから、リポジトリで
`sudo nixos-rebuild switch --flake path:.#shota-nixos`を実行する。
その後ログアウト・ログインし、上記の実機確認を行う。
