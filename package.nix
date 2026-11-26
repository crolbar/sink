{
  lib,
  rustPlatform,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  pkg-config,
  wrapGAppsHook3,
  openssl,
  gtk3,
  webkitgtk_4_1,
  libayatana-appindicator,
  pipewire,
  pulseaudio,
  curl,
  wget,
  xdg-utils,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sink";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "crolbar";
    repo = "sink";
    rev = "10d7a2be7261052cc55778ee08dbe611907fc661";
    sha256 = "sha256-wy9i/DhlexBqM4dc0jjIxy4LnXoeX1Cz+wQA3n7z/fA=";
  };
  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-F/OOt17xJyNYIJT5l9YS+1vHQFUP6wEVGG9ZP9i4oHI=";
  };
  cargoHash = "sha256-igS+7qYJZyEOvHQ0Tu5THtfjzRWAW5SjAcdP/W576v4=";

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    wrapGAppsHook3
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    gtk3
    webkitgtk_4_1
    libayatana-appindicator
    pipewire
  ];

  buildPhase = ''
    runHook preBuild

    npm run tauri build -- --no-bundle

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./target/release/sink $out/bin
    mkdir -p $out/share/applications
    cp ./packaging/linux/us.echo.Sink.desktop $out/share/applications

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libayatana-appindicator]}
      --prefix PATH : ${lib.makeBinPath [pulseaudio pipewire curl wget xdg-utils]}
    )
  '';
})
