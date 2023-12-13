{

  # Syncthing

  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "syncthing";
    relay.enable = true;
    dataDir = "/var/lib/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
    settings = {
      gui = {
        theme = "dark";
      };
      devices = {
        unRAID = {
          addresses = [
            "tcp://192.168.250.41:22000"
          ];
          autoAcceptFolders = true;
          id = "UX2577Y-5VRQD4N-OFNLOSN-HGMUKU5-2ZVPMUS-W7O3OLP-EAAMRBD-7ZW4QAM";
          introducer = true;
        };
      };
      folders = {
        "/home/matt/.local/share/buku" = {
          label = "Buku";
          copyOwnershipFromParent = true;
        };
      };
    };
  };

}
