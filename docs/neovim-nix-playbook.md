# Neovim / Nix playbook

更新: 2026-10-07。Neovim 0.12と現flake.lockに固定されたプラグインが対象。

## 管理と更新

NixがプラグインとTreesitter parser/queryを取得・固定し、lazy.nvimがコードのロードと設定を担当する。
plugins.nixから生成するconfig.nix_plugins manifestでstoreパスを参照する。
pack/startに置くのはlazyのbootstrapだけ。parser/queryのデータはinit.luaでruntimepathへ明示追加する。
Lazyのインストール・更新・buildは使用せず、flakeの更新後にチェック・ビルド・適用する。
Treesitterは常時ロードし、新APIとFileType autocmdでhighlight/indentを有効化する。
TSInstall/TSUpdateで別のparserを導入しない。言語追加はplugins.nixの一覧に行う。

## 日常操作

明示保存だけを行い、移動やFocusLostで保存しない。保存時はConformで整形する。
formatterはプロジェクトローカルが優先、Nixツールがfallback。timeoutは3秒。
SvelteはSvelte LSPのformatterを使う。標準のレジスタでyank/pasteする。
テーマはnightfoxのcarbonfox。

LSPはvim.lsp.config/enableを使用し、全clientでLspAttachから共通キーを登録する。
K=hover、gd=definition、gD=declaration、gi=implementation、gr=references、
leader+rn=rename、leader+ca=code action、挿入時Ctrl-k=signature help。
inlay hintは対応clientだけで有効化する。
leader+ee=ファイルツリー、Ctrl-p=検索、leader+ff=ファイル、leader+sg=grep。

## 不具合確認

ConformInfoでformatterの選択を確認。checkhealth vim.lspでLSP環境を確認。
messagesとLSP logを確認し、起動時だけでなくファイルopen・挿入・保存を再現する。
失敗をpcallで隠さず、必要な機能は通知する。

## 自動検証

nix flake check path:.で隔離したXDG環境のsmoke testを実行する。
plugin設定エラー、全parser、代表言語のhighlight/整形、Svelte LSP、which-key、
通常レジスタ操作、自動保存の無効化、LspAttachの重複防止を検証する。
Nix評価成功やNeovim終了コードだけを正常性の判定にしない。
