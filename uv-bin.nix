{ stdenv, fetchurl, lib, patchelf }:

stdenv.mkDerivation {
  pname = "uv-bin";
  version = "0.5.5";

  src = fetchurl {
    url = "https://github.com/astral-sh/uv/releases/download/${version}/uv-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "3ef767034dec63a33d97424b0494be6afa7e61bcde36ab5aa38d690e89cac69c";
  };

  nativeBuildInputs = [ patchelf ];
  
  phases = [ "unpackPhase" "installPhase" ];
  
  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp uv $out/bin/
    cp uvx $out/bin/
    chmod +x $out/bin/uv
    chmod +x $out/bin/uvx

    # Patch the uv binaries
    for bin in $out/bin/*; do
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" --set-rpath "${stdenv.cc.cc.lib}/lib" $bin
    done
  '';

  meta = with lib; {
    description = "Binary release of uv";
    homepage = "https://github.com/astral-sh/uv";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
