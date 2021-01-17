{ stdenv
, lib
, fetchFromGitHub
, cmake
, gtk3
, doxygen
, python
, glib
, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "eka2l1";
  version = "unstable-2021-01-18";

  src = fetchFromGitHub {
    owner = "EKA2L1";
    repo = "EKA2L1";
    rev = "e011b94a394baa13138fa3d8532e93dc4caa756e";
    sha256 = "1adrx407jqlx2jlakyiawcxpcfgnql58472kbv2pn2mi4smd1gh3";
    fetchSubmodules = true;
  };

  patches = [
    # CMakeLists want to find out commit hash but there's no .git dir anymore.
    ./eka2l1-remove-cmake-git-version-detection.patch
    # Software writes log into same folder as binary.
    ./eka2l1-remove-log-in-bin-dir.patch
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    makeWrapper
  ];

  cmakeFlags = [
    "-DGTK3_GLIBCONFIG_INCLUDE_DIR=${glib.out}/lib/glib-2.0/include"
    "-DGIT_BRANCH=master"
    "-DGIT_COMMIT_HASH=${src.rev}"
  ];

  buildInputs = [
    gtk3
    glib
    python
  ];

  # executable has to be next to its resources so we add a wrapper
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/EKA2L1
    cp -r ./bin/* $out/share/EKA2L1/
    makeWrapper $out/share/EKA2L1/eka2l1 $out/bin/eka2l1
    runHook postInstall
  '';

  meta = with lib; {
    description = "An experimental Symbian OS emulator";
    homepage = "https://github.com/EKA2L1/EKA2L1";
    platforms = platforms.linux;
    maintainers = with maintainers; [ tu-maurice ];
    licenses = with licenses; [ gpl3 ];
  };
}
