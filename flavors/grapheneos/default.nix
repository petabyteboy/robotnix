{ config, pkgs, lib, ... }:
with lib;
let
  kernelName = if (config.deviceFamily == "taimen") then "wahoo" else config.deviceFamily;
  configNameMap = {
    sailfish = "marlin";
    sargo = "bonito";
  };
  grapheneOSRelease = "${config.source.buildNumber}.2020.03.23.22";
in mkIf (config.flavor == "grapheneos") (mkMerge [
(mkIf ((elem config.deviceFamily [ "taimen" "crosshatch" "bonito" ]) || (config.device == "x86")) {
  source.buildNumber = "QQ2A.200305.002";
})
(mkIf (elem config.deviceFamily [ "crosshatch" "bonito" ]) {
  # Hack for crosshatch/bonito since they use submodules and repo2nix doesn't support that yet.
  kernel.src = pkgs.fetchFromGitHub {
    owner = "GrapheneOS";
    repo = "kernel_google_crosshatch";
    rev = grapheneOSRelease;
    sha256 = "08dc9q4bldli85zp0lwc2jqhpqwxclkqg030iq7qm7ygqckb22kh";
    fetchSubmodules = true;
  };
})
{
  buildNumber = mkDefault "2020.03.27.15";
  buildDateTime = mkDefault 1585337099;

  source.jsonFile = ./. + "/${grapheneOSRelease}.json";

  # Not strictly necessary for me to set these, since I override the jsonFile
  source.manifest.url = "https://github.com/GrapheneOS/platform_manifest.git";
  source.manifest.rev = "refs/tags/${grapheneOSRelease}";

  kernel.useCustom = mkDefault true;
  kernel.src = mkDefault config.source.dirs."kernel/google/${kernelName}".contents;
  kernel.configName = mkForce (if (hasAttr config.device configNameMap) then configNameMap.${config.device} else config.device);
  kernel.relpath = mkIf (config.deviceFamily == "taimen") "device/google/taimen-kernel";

  # No need to include these in AOSP build source since we build separately
  source.dirs."kernel/google/marlin".enable = false;
  source.dirs."kernel/google/wahoo".enable = false;
  source.dirs."kernel/google/crosshatch".enable = false;
  source.dirs."kernel/google/bonito".enable = false;

  # Enable Vanadium (GraphaneOS's chromium fork).
  apps.vanadium.enable = mkDefault true;
  webview.vanadium.enable = mkDefault true;
  webview.vanadium.availableByDefault = mkDefault true;

  apps.seedvault.enable = mkDefault true;

# Remove upstream prebuilt versions from build. We build from source ourselves.
  removedProductPackages = [ "TrichromeWebView" "TrichromeChrome" "Seedvault" ];
  source.dirs."external/vanadium".enable = false;
  source.dirs."external/seedvault".enable = false;
  source.dirs."vendor/android-prepare-vendor".enable = false; # Use our own pinned version

  # GrapheneOS just disables apex updating wholesale
  apex.enable = false;

  # Don't include updater by default since it would download updates signed with grapheneos's keys.
  # TODO: Encourage user to set apps.updater.enable
  source.dirs."packages/apps/Updater".enable = false;

  # Leave the existing auditor in the build--just in case the user wants to
  # audit devices using the official upstream build
}
])
