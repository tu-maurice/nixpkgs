{ stdenv
, lib
, fetchFromGitHub
, fuse}:

stdenv.mkDerivation rec {
  pname = "tabfs-unstable";
  version = "2021-01-16";

  src = fetchFromGitHub {
    owner = "osnr";
    repo = "TabFS";
    rev = "82a1d6722def33450733efdffbf94f766ba1fbf5";
    sha256 = "001xnkflch10zqlqjldfvk1fvn70rhrxxm8wajv1gwbp4d01841m";
  };

  passAsFile = [ "firefoxManifest" ];

  firefoxManifest = builtins.toJSON {
    name = "com.rsnous.tabfs";
    description = "TabFS";
    path = "@out@/bin/tabfs";
    type = "stdio";
    allowed_extensions = ["tabfs@rsnous.com"];
  };

  preBuild = ''
    makeFlagsArray+=('CFLAGS+=-I${fuse}/include -L${fuse}/lib $(CFLAGS_EXTRA)')
    cd fs/
  '';

  postBuild = ''
    cd ..
    substituteAll $firefoxManifestPath firefox.json
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/mozilla/native-messaging-hosts $out/share/tabfs/extension
    install -Dm0755 fs/tabfs $out/bin
    install -Dm0644 firefox.json $out/lib/mozilla/native-messaging-hosts/com.rsnous.tabfs.json
    cp -r extension/* $out/share/tabfs/extension
  '';

  meta = with lib; {
    description = "Mount your browser tabs as a filesystem";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ tu-maurice ];
    homepage = "https://omar.website/tabfs/";
  };
}
