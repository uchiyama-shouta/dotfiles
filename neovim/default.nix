{ pkgs, lib, ... }:
let
  plugins = import ./plugins.nix pkgs;
  paths =
    builtins.listToAttrs (
      map (p: {
        name = p.key;
        value = toString p.pkg;
      }) (lib.attrValues plugins)
    )
    // {
      treesitter_runtime = map toString plugins.nvim-treesitter.pkg.dependencies;
    };
  manifest = pkgs.writeText "nix-plugins.lua" ''
    local paths = vim.json.decode([==[${builtins.toJSON paths}]==])
    return setmetatable(paths, { __index = function(_, name)
      error("Unknown Nix plugin: " .. name)
    end })
  '';
  knownKeys = pkgs.writeText "nix-plugin-keys" (lib.concatLines (builtins.attrNames paths));
  nvimConfig = pkgs.runCommand "nvim-config" { } ''
    mkdir -p $out
    cp -r ${./nvim}/. $out/
    chmod -R u+w $out
    cp ${manifest} $out/lua/config/nix_plugins.lua
    if grep -R -E '@[a-z_]+@' $out; then
      echo 'Unresolved Neovim plugin placeholder' >&2
      exit 1
    fi
    for key in $(grep -RhoE 'require\("config.nix_plugins"\)\.[a-z_]+' $out | sed 's/.*\.//' | sort -u); do
      if ! grep -Fxq "$key" ${knownKeys}; then
        echo "Unknown Nix plugin reference: $key" >&2
        exit 1
      fi
    done
  '';
in
{
  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    waylandSupport = false;
    # Keep Home Manager's bootstrap out of the repo-owned init.lua.
    sideloadInitLua = true;
    # lazy loads plugin code; TS data paths are explicitly appended in init.lua.
    plugins = [ plugins.lazy-nvim.pkg ];
    extraPackages = lib.unique (lib.concatMap (p: p.pkg.runtimeDeps or [ ]) (lib.attrValues plugins));
  };
  xdg.configFile."nvim".source = nvimConfig;
}
