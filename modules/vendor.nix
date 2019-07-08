{ config, pkgs, lib, ... }:


with lib;
let
  vendorImgs = {
    marlin = pkgs.fetchurl {
      url = "https://dl.google.com/dl/android/aosp/marlin-pq3a.190705.001-factory-522f27c4.zip";
      sha256 = "522f27c4d50055f6402ca9d4d62fb07425e3af7c4766b647a4096ce3041984ba";
    };
  };
in
{
  options = {
    vendor.img = mkOption {
      default = vendorImgs."${config.deviceFamily}";
      type = types.path;
      description = "A .img from upstream whose vendor contents should be extracted and included in the build";
    };

    vendor.files = mkOption {
      internal = true;
      default = pkgs.callPackage ../android-prepare-vendor {
        inherit (config) device;
        inherit (config.vendor) img;
      };
    };
  };

  config = mkIf (config.vendor.img != null) {
    overlays."".contents = [ config.vendor.files ];
  };
}