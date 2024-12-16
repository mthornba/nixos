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
    openvpn
    packer
    podman
    podman-compose
    pre-commit
    restic
    terraform
    terraform-docs
    tflint
    tfsec
    tshark
    vault
  ];

  programs = {
    k9s = {
      enable =true;
    };
  };
}
