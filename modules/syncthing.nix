let
  user = "matt";
  syncPath = "/var/lib/syncthing";
  bukuPath = "/home/matt/.local/share/buku";
  logseqPath = "/home/matt/Documents/logseq";
in
{

  # Syncthing

  # users.users.syncthing.extraGroups = [ "users" ];
  # systemd.services.syncthing.serviceConfig.UMask = "0007";
  # systemd.tmpfiles.rules = [
  #   "d ${bukuPath} 0770 ${user} syncthing"
  # ];

  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "syncthing";
    relay.enable = true;
    dataDir = "${syncPath}";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
    settings = {
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
        "buku" = {
          id = "jjcxm-tvhvg";
          devices = [ "unRAID" ];
          path = "~/buku";
        };
        "logseq" = {
          id = "zvwsu-btepb";
          devices = [ "unRAID" ];
          path = "~/logseq";
        };
      };
      gui = {
        theme = "dark";
      };
      options = {
        urAccepted = -1;
      };
    };
  };

  # bind mount sync folder to buku data dir
  fileSystems."buku" = {
    mountPoint = "${bukuPath}";
    device = "${syncPath}/buku";
    options = [ "bind" ];
  };

}
