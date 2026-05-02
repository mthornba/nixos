{ config, lib, pkgs, ... }:

{
  home.packages = [
    (pkgs.buildGoModule rec {
      pname = "lsq";
      version = "1.5.0";

      src = pkgs.fetchFromGitHub {
        owner = "jrswab";
        repo = "lsq";
        rev = "v${version}";
        hash = "sha256-sgCYjkV39dG40v4KuX1BOCr5FIrB66l2oueBzHeoNwI=";
      };

      vendorHash = "sha256-fl9v/yTQ2K8Bwekp5xCVvoPP7bNgRtYOLZ/Hkie0ek8=";

      # Repository doesn't have proper vendor directory
      proxyVendor = true;

      meta = with lib; {
        description = "A TUI for managing your to-do list in todo.txt format";
        homepage = "https://github.com/jrswab/lsq";
        license = licenses.gpl3Only;
        mainProgram = "lsq";
      };
    })
  ];
}
