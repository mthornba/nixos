{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    drone-cli
    helm-docs
    krew
    ktop
    kubecolor
    kubectl
    kubectx
    kubespy
    kubernetes-helm
    minio-client
    packer
    podman
    pre-commit
    terraform
    terraform-docs
    tflint
    tfsec
    tshark
  ];

  programs = {
    k9s = {
      enable =true;
    };
  };
}
