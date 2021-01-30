{ stdenv
, lib
, fetchhg
, xlibsWrapper
, installShellFiles }:

stdenv.mkDerivation rec {
  name = "drawterm-9front";
  version = "unstable-2020-01-30";

  src = fetchhg {
    inherit name;
    url = "https://code.9front.org/hg/drawterm";
    rev = "8fd69c7dfe88";
    sha256 = "18wjxrgxpav4ckpfv754cj7zwkbrgvpahs250dhxscw91hsz3y06";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
    xlibsWrapper
  ];

  makeFlags = [
    "CONF=unix"
    "X11=/var/empty" # stdenv already handles include paths
  ];

  installPhase = ''
    install -Dm755 drawterm $out/bin/drawterm
    installManPage drawterm.1
  '';

  meta = with lib; {
    description = "Russ Cox's drawterm with features from Plan9front";
    longDescription = ''
      This is a fork of Russ Cox's drawterm to incorporate features
      from Plan9front (http://9front.org), most importantly DP9IK
      authentication support (see authsrv(6)) and the TLS based rcpu(1)
      protocol.
    '';
    homepage = "http://drawterm.9front.org/";
    license = licenses.lpl-102;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
