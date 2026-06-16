{ config, lib, pkgs, ... }:

{
  programs ={
    opencode = {
      enable = true;
      extraPackages = with pkgs; [ beads ];
      settings = {
        model = "ollama/qwen3-8b-nothink";
        autoupdate = false;
        share = "disabled";
        # Only use ollama — don't prompt for cloud provider keys
        enabled_providers = [ "ollama" ];
        provider = {
          ollama = {
            options = {
              baseURL = "http://localhost:11434/v1";
            };
            models = {
              "qwen3-8b-nothink" = {
                id = "qwen3-8b-nothink";
                name = "Qwen3 8B (no think)";
              };
            };
          };
        };
      };
    };
  };
}

