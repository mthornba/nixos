{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    openvscode-server
  ];

  systemd.user.services = {
    ovsc-server = {
      Unit = {
        Description = "OpenVSCode Server";
        Documentation = [ "https://github.com/gitpod-io/openvscode-server" ];
      };

      Service = {
        Type = "exec";
        ExecStart = ''
          ${pkgs.openvscode-server}/bin/openvscode-server \
          --host 0.0.0.0 --port 3000 \
          --without-connection-token \
	        --telemetry-level off
        '';
        Restart = "always";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  systemd.user.startServices = "sd-switch";
}
