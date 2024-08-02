{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    drone-cli
    helm-docs
    ktop
    kubecolor
    kubectl
    kubectx
    kubespy
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
