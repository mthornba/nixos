{ config, lib, pkgs, ... }:

{
  programs = {
    opencode = {
      enable = true;
      extraPackages = with pkgs; [ beads ];

      settings = {
        "$schema" = "https://opencode.ai/config.json";

        model = "ollama/qwen3-coder-next-64k";
        small_model = "ollama/qwen3-8b-64k";

        autoupdate = false;
        share = "disabled";

        enabled_providers = [ "ollama" ];

        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama";

            options = {
              baseURL = "http://localhost:11434/v1";
              timeout = 600000;
              chunkTimeout = 60000;
            };

            models = {
              "qwen3-coder-next-64k" = {
                name = "Qwen3 Coder Next 64K";

                limit = {
                  context = 65536;
                  output = 8192;
                };
              };

              "qwen3-8b-64k" = {
                name = "Qwen3 8B 64K";

                limit = {
                  context = 65536;
                  output = 8192;
                };
              };
            };
          };
        };

        compaction = {
          auto = true;
          prune = true;
          reserved = 10000;
        };
      };
    };
  };
}
