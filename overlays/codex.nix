final: prev:

let
  version = "0.164.0";

  codexSrc = final.fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}.tgz";
    hash = "sha512-TWj7UGyPRe3Pj/A3ddNAxs1te3a/W/xAd+J0LHrrFTmsSfahGMOLF/vn88D3QCIgAT3B1rm1y/Z3NYE0rx6cZQ==";
  };

  codexLinuxX64Src = final.fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}-linux-x64.tgz";
    hash = "sha512-XLAoaWsGOT2khzl+P4FYDPTkzAr9W0VFXFaVkqlFdkM0soa1gH/4S0wSD57Ek3HHwkirAEGz2/Mwehseh+l5Mg==";
  };
in
{
  codex = final.stdenvNoCC.mkDerivation {
    pname = "codex";
    inherit version;

    nativeBuildInputs = [ final.makeWrapper ];

    unpackPhase = ''
      runHook preUnpack

      mkdir codex codex-linux-x64
      tar -xzf ${codexSrc} -C codex
      tar -xzf ${codexLinuxX64Src} -C codex-linux-x64

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib/node_modules/@openai" "$out/bin"
      cp -R codex/package "$out/lib/node_modules/@openai/codex"
      cp -R codex-linux-x64/package "$out/lib/node_modules/@openai/codex-linux-x64"

      makeWrapper ${final.nodejs_22}/bin/node "$out/bin/codex" \
        --add-flags "$out/lib/node_modules/@openai/codex/bin/codex.js" \
        --prefix PATH : ${
          final.lib.makeBinPath [
            final.ripgrep
            final.bubblewrap
          ]
        }

      runHook postInstall
    '';

    meta = {
      description = "Codex CLI is a coding agent from OpenAI that runs locally on your computer";
      homepage = "https://github.com/openai/codex";
      license = final.lib.licenses.asl20;
      mainProgram = "codex";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with final.lib.sourceTypes; [ binaryNativeCode ];
    };
  };
}
