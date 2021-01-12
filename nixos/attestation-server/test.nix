{ pkgs }:

import "${pkgs.path}/nixos/tests/make-test-python.nix" ({ pkgs, ... }: {
  name = "attestation-server";

  machine = { ... }: {
    imports = [ ../default.nix ];

    services.attestation-server = {
      enable = true;
      domain = "example.com";
      device = "crosshatch";
      signatureFingerprint = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
      avbFingerprint = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
      # TODO: Uncomment when https://github.com/danielfullmer/robotnix/issues/80 is resolved
      # email = {
      #   host = "example.com";
      #   username = "test";
      #   passwordFile = "${pkgs.writeText "fake-password" "testing123"}"; # NOTE: Don't use writeText like this with a real password!
      # };
      nginx.enable = false;
    };
  };

  testScript = ''
    machine.wait_for_unit("attestation-server.service")
    machine.wait_until_succeeds("curl http://127.0.0.1:8085/")
  '';
})