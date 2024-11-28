{ pkgs ? import <nixpkgs> {} }:

let
  uvBin = import ./uv-bin.nix {
    inherit (pkgs) stdenv fetchurl lib patchelf;
  };

  # Derivation to download weights and generate cache_paths.txt
  downloadWeights = pkgs.runCommand "download-weights" {
    buildInputs = [ pkgs.python3 pkgs.python3Packages.pip uvBin ];
  } ''
    # Copy your application files
    mkdir -p $out/app/src
    cp -r ${./src} $out/app/src
    cp ${./pyproject.toml} $out/app/
    cp ${./uv.lock} $out/app/
    cp ${./README.md} $out/app/

    export HOME=$out
    export PATH=${uvBin}/bin:$PATH

    cd $out/app

    uv sync --frozen

    # Run the download_weights.py script
    python src/docling/download_weights.py --cache_paths_file $out/app/cache_paths.txt
  '';

in

{
  finalImage = pkgs.dockerTools.buildImage {
    name = "final-image";
    fromImage = "python:3.11-slim";

    copyToRoot = pkgs.buildEnv {
      name = "final-env";
      paths = [
        uvBin

        # Include cache_paths.txt at /app/cache_paths.txt
        (pkgs.runCommand "include-cache_paths.txt" {} ''
          mkdir -p $out/app
          cp ${downloadWeights}/app/cache_paths.txt $out/app/
        '')

        # Include the cached weights
        (pkgs.runCommand "include-cache" {} ''
          mkdir -p $out/root/.cache
          cp -r ${downloadWeights}/.cache/* $out/root/.cache/
        '')
      ];
    };

    config = {
      WorkingDir = "/app";
      Env = [
        "PATH=${pkgs.lib.makeBinPath [ uvBin ]}:$PATH"
      ];
      Entrypoint = [ "uv" "run" "src/docling/convert.py" ];
    };

    runAsRoot = ''
      mkdir -p /app
    '';

    extraCommands = ''
      COPY ./pyproject.toml ./uv.lock ./README.md ./
      COPY ./src ./src

      # Install dependencies
      RUN uv sync --frozen
    '';
  };
}
