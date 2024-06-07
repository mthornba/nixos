let
  user = "matt";
  userShare = "/home/${user}/.local/share";
  userConfig = "/home/${user}/.config";
  syncPath = "/var/lib/syncthing";
  bukuPath = "${userShare}/buku";
  logseqPath = "${userShare}/logseq";
in
{

  # Syncthing

  # users.users.syncthing.extraGroups = [ "users" ];
  # systemd.services.syncthing.serviceConfig.UMask = "0007";

  # for syntax, see https://man.archlinux.org/man/tmpfiles.d.5
  systemd.tmpfiles.rules = [
    "d ${bukuPath} 0775 ${user} users"
    "d ${logseqPath} 0775 ${user} users"
    "d ${syncPath} 0775 ${user} users"
  ];

  services.syncthing = {
    enable = true;
    user = "${user}";
    group = "users";
    relay.enable = true;
    dataDir = "${syncPath}";
    configDir = "${userConfig}/syncthing";
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
          path = "${bukuPath}";
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "15768000";
            };
          };
        };
        "logseq" = {
          id = "zvwsu-btepb";
          devices = [ "unRAID" ];
          path = "${logseqPath}";
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "15768000";
            };
          };
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

  # bind mount sync folders

  # fileSystems."buku" = {
  #   mountPoint = "${bukuPath}";
  #   device = "${syncPath}/buku";
  #   options = [ "bind" ];
  # };

  # fileSystems."logseq" = {
  #   mountPoint = "${logseqPath}";
  #   device = "${syncPath}/logseq";
  #   options = [ "bind" ];
  # };

}
