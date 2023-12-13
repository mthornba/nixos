{ pkgs, ... }:

{

  # Webcam
  services = {
    mjpg-streamer = {
      enable = true;
      outputPlugin = "output_http.so -p 8080 -w ${pkgs.mjpg-streamer}/share/mjpg-streamer/www";
      # outputPlugin = "output_http.so -p 8080 -w /nix/store/g2831x2a4843xzfabn4hpc6lkqyqzn43-mjpg-streamer-unstable-2019-05-24/share/mjpg-streamer/www";
      inputPlugin = "input_uvc.so -r 1280x960 -f 10 -d /dev/video0 -y";
    };
  };

  # Octoprint
  services.octoprint = {
    enable = true;
    openFirewall = true;
    port = 5000;
    user = "octoprint";
    extraConfig = {
      plugins = {
        classicwebcam = {
          snapshot = "http://localhost:8080/?action=snapshot";
          stream = "http://localhost:8080/?action=stream";
        };
        tracking.enabled = false;
      };
      server = {
        commands = {
          serverRestartCommand = "sudo systemctl restart octoprint";
        };
        firstRun = false;
        host = "0.0.0.0";
        onlineCheck.enabled = true;
        pluginBlacklist.enabled = true;
        seenWizards = {
          backup = null;
          classicwebcam = 1;
          corewizard = 4;
          tracking = null;
        };
      };
      temperature = {
        profiles = [
          {
            bed = 90;
            chamber = null;
            extruder = 230;
            name = "PETG";
          }
          {
            bed = 90;
            chamber = null;
            extruder = 0;
            name = "PETG (bed only)";
          }
          {
            bed = 60;
            chamber = null;
            extruder = 180;
            name = "PLA";
          }
        ];
      };
    };
  };

}
