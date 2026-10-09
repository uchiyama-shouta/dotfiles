# NixOS / WSL の差分調査（2026-10-10）

## 調査範囲

現在のリポジトリのホスト設定に加え、同じflake.lockからNixOSの組み込みHome ManagerとWSLのstandalone Home Managerをoffline評価した。パッケージのstore path、生成ファイル、シェル設定、session変数、user serviceを比較した。WSL実機には接続していないため、適用済み世代、別途導入したツール、Windows側端末の設定は未確認。

## 優先して解消する差：Codex

- NixOSは `hosts/shota-nixos/home-manager.nix` で `codex` を導入している。
- Ubuntuも `hosts/shota/home-manager.nix` で導入している。
- WSLは `hosts/shouta/home-manager.nix` のホスト固有packagesが空で、共通packagesにもCodexがない。評価済みのWSLパッケージ一覧にも存在しない。
- `flake.nix` は全ホストへ同じCodex overlayを渡しているが、overlayはパッケージ定義を提供するだけでインストールしない。
- `tests/checks.nix` のCodex checkは `pkgs.codex` を直接実行する。そのため、WSLの導入一覧から抜けていてもテストは成功する。

したがってWSLの `home-manager switch` でCodexが利用可能になる保証はない。以前のHome Manager世代から供給されていた場合、switch後の有効なprofileから消える可能性がある。npmや別のNix profile等で導入済みなら残り得るが、バージョンと依存は本dotfilesの管理外になる。実際の導入元はWSLで `command -v codex` と `readlink -f "$(command -v codex)"` により確認する。

全ホストで利用する要件なら、修正は `codex` を共通Home Managerのpackagesへ移し、ホスト固有の重複を除去するのが自然。あわせて全ホストの評価済みpackagesにCodexが含まれることを検証する。今回の調査では設定変更は行っていない。

## その他の差分

| 項目 | NixOS | WSL | 影響・判定 |
| --- | --- | --- | --- |
| ユーザー / HOME | shota / /home/shota | shouta / /home/shouta | 意図したホスト差。WSL実ユーザーとの一致は要確認 |
| 追加ツール | Codex、htop、Hack Nerd Font、Firefox | いずれも導入なし | Codex/htopはCLI機能の差。Firefoxはデスクトップ用途の差 |
| フォント | Hack Nerd Fontを導入 | fontconfigのみ、Hack未導入 | アイコンの表示差につながる。Windows側端末を使う場合はそちらのフォント設定も必要 |
| ログインシェル | OS設定でzshを指定 | zshの導入・設定のみ | HMはOSアカウントのデフォルトシェルを変更しない。WSLがbashで起動するとzsh設定や自動鍵解除は実行されない |
| Nix / HM適用 | system設定とHMをまとめてswitch | standalone HMをswitch | WSLのOS設定は対象外。WSLにはHMコマンド自体もprofileへ導入される |
| パッケージprofile | NixOSのuseUserPackages=trueによるユーザーprofile | standalone HMのprofile | PATHとprofileの初期化方式が異なる。実機のPATH/コマンド解決は未確認 |
| SSH agent | systemd userとGUIログイン基盤をOSで提供 | systemd/user sessionをOS側で準備する必要 | service定義は同一でもWSLでuser bus/runtime dirがなければ鍵解除に失敗 |
| 鍵解除frontend | KDE autostartとTTY | 同じKDE/autostart設定が生成される | KDE用設定は通常のWSL端末起動では働かない。zshの初回TTY解除に依存 |
| SSH鍵・GitHub認証 | 実機で鍵と認証導入済み | ホストごとに準備が必要 | 鍵やgh認証情報はNixからコピーされない。ファイル名は共通 |
| Docker | daemon有効、dockerグループ付与 | CLIとComposeのみ | WSLのdaemon導入、起動、グループ付与は別作業 |
| locale / timezone | ja_JP.UTF-8 / Asia/TokyoをOSで指定 | OS設定を継承 | 言語・日時の差が出得る。生成されたlocale archiveも異なる |
| GUI・入力・配信 | KDE/SDDM、fcitx5、Sunshine、LAN firewall | 対応するOS設定なし | NixOS固有の意図した差 |
| テスト対象 | 全ホストをビルド | WSLもビルド | 動作checksはUbuntu HM設定を使用。WSLのログイン・導入済みCLIを直接検証していない |

## 同一と確認できた設定

- NeovimのfinalPackageは同じstore path（0.12.2）。生成nvim設定とplugin packも同じsource。LSP/formatterを含む共通ツールも同じパッケージ。
- zshのinitContentと生成zshrcはHOMEの置換を除いて同一。aliases、fzf、Starship、autosuggestions、syntax highlightingは共通。
- SSH agentのservice定義は完全一致。ssh-unlock、固定socketの方針、Git署名設定は共通。Git設定の差はallowed signersのHOME部分のみ。
- tmuxと独自clipboard設定は両ホストとも削除済み。

共通設定が同じでも、WSLで別の `nvim` / `git` / `zsh` がPATH上で先に見つかる場合や設定が未適用なら動作は異なる。この点は生成構成の比較だけでは断定しない。

## 修正方針と対応

上記は修正前の比較記録。開発ツールと操作は揃え、OSの起動・導入方式は各環境に合わせる。

- Codexとhtopを共通Home Managerへ移し、ホスト固有の重複を削除した。
- 全ホストの評価済みhome.packagesに必須CLIが存在するcheckを追加した。Codex単体の起動checkだけでは検出できなかった導入漏れを検出する。
- WSLのログインシェル、systemd user session、SSH鍵・GitHub認証、Docker daemonの準備はREADMEで扱う。OSアカウント変更をHome Manager activationへ混在させない。
- NixOSのフォント・GUI・Sunshineはホスト固有のまま。Windows端末のフォント設定はdotfilesの責務外であり、差異を不具合として扱わない。
- ユーザー名、HOME、profileの配置、OS locale/timezoneの違いは維持する。
