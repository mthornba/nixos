{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    argocd
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
    podman-compose
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
