{ stdenv
, lib
, fetchFromGitHub
, cmake
, libxml2
, libpeas
, glib
, gtk3
, gtksourceview3
, gspell
, xapps
, pkgconfig
, meson
, ninja
, wrapGAppsHook
, intltool
, itstool }:

stdenv.mkDerivation rec {
  pname = "xed-editor";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "xed";
    rev = version;
    sha256 = "129a1l3ghl4b8mqc7g3d6k1f8wkwy3vxv17f857psv21cb05wcpm";
  };

  nativeBuildInputs = [
    meson
    cmake
    pkgconfig
    intltool
    itstool
    ninja
    wrapGAppsHook
  ];

  buildInputs = [
    libxml2
    glib
    gtk3
    gtksourceview3
    libpeas
    gspell
    xapps
  ];

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  meta = with lib; {
    description = "Light weight text editor from Linux Mint";
    homepage = "https://github.com/linuxmint/xed";
    licenses = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ tu-maurice ];
  };
}
