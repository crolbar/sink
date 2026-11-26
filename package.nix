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
    rev = "b58e95e90c4e4c892041bb99f725996e24ce993e";
    sha256 = "sha256-IVXKKjWxcXmNwuzDAs+mqRk2tI1EmLv9hezKN00saTQ=";
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
