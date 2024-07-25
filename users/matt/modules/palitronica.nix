{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    azure-cli
    drone-cli
    helm-docs
    kubectl
    kubernetes-helm
    minio-client
    packer
    podman
    terraform
    terraform-docs
    tflint
    tfsec
  ];

  programs = {
    k9s = {
      enable =true;
    };
  };
}
