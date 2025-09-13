{ pkgs, config, lib, replaceVars, ... }:
let
  plugins = import ./plugins.nix pkgs;

  # dirVar -> 実際のパッケージパス の対応表を作る
  # 例: { lazy_nvim = "/nix/store/abc123..."; nvim_tree_lua = "/nix/store/xyz456..."; }
  vars = builtins.listToAttrs (map (p: {
    name = p.dirVar;
    value = "${p.pkg}";
  }) (lib.attrValues plugins));

  # Neovim 設定ディレクトリをコピーして @...@ を /nix/store/... に置換するビルド
  nvimWithVars = pkgs.runCommand "nvim-config" { } ''
    mkdir -p $out
    cp -r ${./nvim}/* $out/
    chmod -R u+w $out
    # Lua/VimScript ファイル内の @dirVar@ を実パスに置換
    for file in $(find $out -type f \( -name '*.lua' -o -name '*.vim' \)); do
      sed ${
        lib.concatStringsSep " "
        (lib.mapAttrsToList (n: v: "-e 's|@${n}@|${v}|g'") vars)
      } -i "$file"
    done
  '';
in {
  programs.neovim = {
    enable = true;
    plugins = map (p: p.pkg) (lib.attrValues plugins);
  };
  xdg.configFile."nvim".source = nvimWithVars;
}
