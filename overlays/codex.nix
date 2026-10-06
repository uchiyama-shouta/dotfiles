final: prev:

let
  version = "0.160.1";

  codexSrc = final.fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}.tgz";
    hash = "sha512-f1yrJhwgimKQI1kYQlxdPJcFwkNZxZrbz7Hf89EAcnLqkQ7TiESzr2FgSZn13Ga5RuHjlVUfurzwq10wk9zw2g==";
  };

  codexLinuxX64Src = final.fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}-linux-x64.tgz";
    hash = "sha512-sIDhqV+bsZKKVaVFVY5iB+pAzyOz2XRm3H1KXCsSJwGj5p98qnrT0Fweo1Hfe7WnyTp8mfBNdbVzUeO+mHYugA==";
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
        --prefix PATH : ${final.lib.makeBinPath [
          final.ripgrep
          final.bubblewrap
        ]}

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
